//
//  Copyright (C) 2020 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Accelerate
import CoreMedia
import CoreVideo
import Dispatch
import ReplayKit
import TwilioVideo

class ReplayKitVideoSource: NSObject {
    // In order to save memory, the handler may request that the source downscale its output.
    static let kDownScaledMaxWidthOrHeight = UInt(886)
    static let kDownScaledMaxWidthOrHeightSimulcast = UInt(1280)

    // Maximum bitrate (in kbps) used to send video.
    static let kMaxVideoBitrate = UInt(1440)
    // The simulcast encoder allocates bits for each layer.
    static let kMaxVideoBitrateSimulcast = UInt(1180)
    static let kMaxScreenshareBitrate = UInt(1600)

    // Maximum frame rate to send video at.
    static let kMaxVideoFrameRate = UInt(15)

    /*
     * Streaming video content at 30 fps or lower is ideal, especially in variable network conditions.
     * In order to improve the quality of screen sharing, these constants optimize for specific use cases:
     *
     *  1. App content: Stream at 15 fps to ensure fine details (spatial resolution) are maintained.
     *  2. Video content: Attempt to match the natural video cadence between kMinSyncFrameRate <= fps <= kMaxSyncFrameRate.
     *  3. Telecined Video content: Some apps perform a telecine by drawing to the screen using more vsyncs than are needed.
     *     When this occurs, ReplayKit generates duplicate frames, decimating the content further to 30 Hz.
     *     Duplicate video frames reduce encoder performance, increase cpu usage and lower the quality of the video stream.
     *     When the source detects telecined content, it attempts an inverse telecine to restore the natural cadence.
     */
    static let kMaxSyncFrameRate = UInt(27)
    static let kMinSyncFrameRate = UInt(22)
    static let kFrameHistorySize = 16

    /*
     * Enable retransmission of the last sent frame. This feature consumes some memory, CPU, and bandwidth but it ensures
     * that your most recent frame eventually reaches subscribers, and that the publisher has a reasonable bandwidth estimate
     * for the next time a new frame is captured.
     */
    static let retransmitLastFrame = true
    static let kFrameRetransmitIntervalMs = Int(250)
    static let kFrameRetransmitTimeInterval = CMTime(value: CMTimeValue(kFrameRetransmitIntervalMs),
                                                     timescale: CMTimeScale(1000))
    static let kFrameRetransmitDispatchInterval = DispatchTimeInterval.milliseconds(kFrameRetransmitIntervalMs)
    static let kFrameRetransmitDispatchLeeway = DispatchTimeInterval.milliseconds(20)

    private var screencastUsage: Bool = false
    @objc weak var sink: VideoSink?
    private var videoFormat: VideoFormat?
    private var frameSync: Bool = false
    private var frameSyncRestorableFrameRate: UInt?

    private var averageDelivered = UInt32(0)
    private var recentDelivered = UInt32(0)

    // Used to detect a sequence of video frames that have 3:2 pulldown applied
    private var recentDeliveredFrameDeltas: [CMTime] = []
    private var lastInputTimestamp: CMTime?
    private var recentInputFrameDeltas: [CMTime] = []

    private var videoQueue: DispatchQueue?
    private var timerSource: DispatchSourceTimer?
    private var lastTransmitTimestamp: CMTime?
    private var lastFrameStorage: VideoFrame?
    // ReplayKit reuses the underlying CVPixelBuffer if you release the CMSampleBuffer back to their pool.
    // Holding on to the last frame is a poor-man's workaround to prevent image corruption.
    private var lastSampleBuffer: CMSampleBuffer?

    override init() {
        let isScreencast = true
        
        screencastUsage = isScreencast
        super.init()
    }

    public var isScreencast: Bool {
        get {
            return screencastUsage
        }
    }

    func requestOutputFormat(_ outputFormat: VideoFormat) {
        videoFormat = outputFormat

        if let sink = sink {
            sink.onVideoFormatRequest(videoFormat)
        }
    }

    /// Provide a frame to the source for processing. This operation might result in the frame being delivered to the sink,
    /// dropped, and/or remapped.
    ///
    /// - Parameter sampleBuffer: The new CMSampleBuffer input to process.
    @objc func processFrame(sampleBuffer: CMSampleBuffer) {
        guard let sink = self.sink else {
            return
        }

        guard let sourcePixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            assertionFailure("SampleBuffer did not have an ImageBuffer")
            return
        }
        // The source only supports NV12 (full-range) buffers.
        let pixelFormat = CVPixelBufferGetPixelFormatType(sourcePixelBuffer);
        if (pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            assertionFailure("Extension assumes the incoming frames are of type NV12")
            return
        }

        // Discover the dispatch queue that ReplayKit is operating on.
        if videoQueue == nil {
            videoQueue = ExampleCoreAudioDeviceGetCurrentQueue()
        }

        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        /*
         * Check rotation tags. Extensions see these tags, but `RPScreenRecorder` does not appear to set them.
         * On iOS 12.0 and 13.0 rotation tags (other than up) are set by extensions.
         */
        var videoOrientation = VideoOrientation.up
        if let sampleOrientation = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil),
            let coreSampleOrientation = sampleOrientation.uint32Value {
            videoOrientation
                = ReplayKitVideoSource.imageOrientationToVideoOrientation(imageOrientation: CGImagePropertyOrientation(rawValue: coreSampleOrientation)!)
        }

        /*
         * Return the original pixel buffer without any downscaling or cropping applied.
         * You may use a format request to crop and/or scale the buffers produced by this class.
         */
        deliverFrame(to: sink,
                     timestamp: timestamp,
                     buffer: sourcePixelBuffer,
                     orientation: videoOrientation,
                     forceReschedule: false)

        // Hold on to the previous sample buffer to prevent tearing.
        lastSampleBuffer = sampleBuffer
    }

    private func deliverFrame(to: VideoSink, timestamp: CMTime, buffer: CVPixelBuffer, orientation: VideoOrientation, forceReschedule: Bool) {
        guard let frame = VideoFrame(timestamp: timestamp,
                                     buffer: buffer,
                                     orientation: orientation) else {
                                        assertionFailure("Couldn't create a VideoFrame with a valid CVPixelBuffer.")
                                        return
        }
        to.onVideoFrame(frame)

        // Frame retransmission logic.
        if (ReplayKitVideoSource.retransmitLastFrame) {
            lastFrameStorage = frame
            lastTransmitTimestamp = CMClockGetTime(CMClockGetHostTimeClock())
            dispatchRetransmissions(forceReschedule: forceReschedule)
        }
    }

    private func dispatchRetransmissions(forceReschedule: Bool) {
        if let source = timerSource,
            source.isCancelled == false,
            forceReschedule == false {
            // No work to do, wait for the next timer to fire and re-evaluate.
            return
        }
        // We require a queue to create a timer source.
        guard let currentQueue = videoQueue else {
            return
        }

        let source = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.strict,
                                                    queue: currentQueue)
        timerSource = source

        // Generally, this timer is invoked in kFrameRetransmitDispatchInterval when no frames are sent.
        source.setEventHandler(handler: {
            if let frame = self.lastFrameStorage,
                let sink = self.sink,
                let lastHostTimestamp = self.lastTransmitTimestamp {
                let currentTimestamp = CMClockGetTime(CMClockGetHostTimeClock())
                let delta = CMTimeSubtract(currentTimestamp, lastHostTimestamp)

                if delta >= ReplayKitVideoSource.kFrameRetransmitTimeInterval {
                    #if DEBUG
                    print("Delivering frame since send delta is greather than threshold. delta=", delta.seconds)
                    #endif
                    // Reconstruct a new timestamp, advancing by our relative read of host time.
                    self.deliverFrame(to: sink,
                                      timestamp: CMTimeAdd(frame.timestamp, delta),
                                      buffer: frame.imageBuffer,
                                      orientation: frame.orientation,
                                      forceReschedule: true)
                } else {
                    // Reschedule for when the next retransmission might be required.
                    let remaining = ReplayKitVideoSource.kFrameRetransmitTimeInterval.seconds - delta.seconds
                    let deadline = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(remaining * 1000.0))
                    self.timerSource?.schedule(deadline: deadline, leeway: ReplayKitVideoSource.kFrameRetransmitDispatchLeeway)
                }
            }
        })

        // Thread safe cleanup of temporary storage, in case of cancellation. Normally, we reschedule.
        source.setCancelHandler(handler: {
            self.lastFrameStorage = nil
        })

        // Schedule a first time source for the full interval.
        let deadline = DispatchTime.now() + ReplayKitVideoSource.kFrameRetransmitDispatchInterval
        source.schedule(deadline: deadline, leeway: ReplayKitVideoSource.kFrameRetransmitDispatchLeeway)
        source.activate()
    }

    private static func imageOrientationToVideoOrientation(imageOrientation: CGImagePropertyOrientation) -> VideoOrientation {
        let videoOrientation: VideoOrientation

        // Note: The source does not attempt to "undo" mirroring. So far I have not encountered mirrored tags from ReplayKit sources.
        switch imageOrientation {
        case .up:
            videoOrientation = VideoOrientation.up
        case .upMirrored:
            videoOrientation = VideoOrientation.up
        case .left:
            videoOrientation = VideoOrientation.left
        case .leftMirrored:
            videoOrientation = VideoOrientation.left
        case .right:
            videoOrientation = VideoOrientation.right
        case .rightMirrored:
            videoOrientation = VideoOrientation.right
        case .down:
            videoOrientation = VideoOrientation.down
        case .downMirrored:
            videoOrientation = VideoOrientation.down
        }

        return videoOrientation
    }
}
