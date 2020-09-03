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

#import <CoreVideo/CoreVideo.h>
#import <ReplayKit/ReplayKit.h>

#import "TVIReplayKitVideoFrameFactory.h"

@implementation TVIReplayKitVideoFrameFactory

- (TVIVideoFrame *)makeVideoFrameWithSample:(CMSampleBufferRef)sampleBuffer
                                  timestamp:(CMTime)timestamp {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if (imageBuffer == nil) { // Does nil work?
        return nil;
    }
    
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
    
    if (pixelFormat != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        return nil;
    }
    
    TVIVideoFrame *videoFrame = [[TVIVideoFrame alloc] initWithTimestamp:timestamp
                                                                  buffer:imageBuffer
                                                             orientation:TVIVideoOrientationUp]; // Fix
    
    if (videoFrame == nil) {
        return nil;
    }
    
    return videoFrame;
}

- (CGImagePropertyOrientation)imageOrientationForSample:(CMSampleBufferRef)sampleBuffer {
    CFTypeRef attachment = CMGetAttachment(sampleBuffer, (CFStringRef)RPVideoSampleOrientationKey, nil);
    
    return (uint32_t)attachment;
}

- (TVIVideoOrientation)videoOrientationForImageOrientation:(CGImagePropertyOrientation)imageOrientation {
    switch (imageOrientation) {
        case kCGImagePropertyOrientationUp:
        case kCGImagePropertyOrientationUpMirrored:
            return TVIVideoOrientationUp;
        case kCGImagePropertyOrientationLeft:
        case kCGImagePropertyOrientationLeftMirrored:
            return TVIVideoOrientationLeft;
        case kCGImagePropertyOrientationRight:
        case kCGImagePropertyOrientationRightMirrored:
            return TVIVideoOrientationRight;
        case kCGImagePropertyOrientationDown:
        case kCGImagePropertyOrientationDownMirrored:
            return TVIVideoOrientationDown;
    }
}

@end
