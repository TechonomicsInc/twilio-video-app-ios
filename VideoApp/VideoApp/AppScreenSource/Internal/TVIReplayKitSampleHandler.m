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

#import "TVIReplayKitSampleHandler.h"
#import "TVIReplayKitVideoFrameFactory.h"
#import "TVIVideoFrameTransmitter.h"

@interface TVIReplayKitSampleHandler()

@property (nonatomic, retain) TVIReplayKitVideoFrameFactory *videoFrameFactory;
@property (nonatomic, retain) TVIVideoFrameTransmitter *transmitter;

@end

@implementation TVIReplayKitSampleHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        _videoFrameFactory = [TVIReplayKitVideoFrameFactory new];
        _transmitter = [TVIVideoFrameTransmitter new];
    }
    return self;
}

- (void)handleSample:(CMSampleBufferRef)sampleBuffer
          bufferType:(RPSampleBufferType)bufferType
                sink:(id<TVIVideoSink>)sink {
    switch (bufferType) {
        case RPSampleBufferTypeVideo:
            [self handleVideoSample:sampleBuffer sink:sink];
            break;
        case RPSampleBufferTypeAudioApp:
        case RPSampleBufferTypeAudioMic:
            break;
    }
}

- (void)handleVideoSample:(CMSampleBufferRef)sampleBuffer
                     sink:(id<TVIVideoSink>)sink {
    NSParameterAssert(sampleBuffer);
    NSParameterAssert(sink);
    
    TVIVideoFrame *videoFrame = [self.videoFrameFactory makeVideoFrameWithSample:sampleBuffer];

    if (!videoFrame) {
        return;
    }
    
    // Transform variable frame rate from ReplayKit to constant frame rate that is ideal for WebRTC
    [self.transmitter transmitVideoFrame:videoFrame sink:sink];
}

@end
