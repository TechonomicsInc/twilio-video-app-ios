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

#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <ReplayKit/ReplayKit.h>

#import "TVIReplayKitVideoFrameFactory.h"

static TVIVideoOrientation SampleBufferGetOrientation(CMSampleBufferRef sampleBuffer) {
    NSNumber *orientation = (NSNumber *)CMGetAttachment(sampleBuffer, (CFStringRef)RPVideoSampleOrientationKey, nil);
    
    // RPScreenRecorder does not appear to set orientation but RPBroadcastSampleHandler does
    if (!orientation) {
        return TVIVideoOrientationUp;
    }
    
    switch ((CGImagePropertyOrientation)orientation) {
        case kCGImagePropertyOrientationUp: return TVIVideoOrientationUp;
        case kCGImagePropertyOrientationUpMirrored: return TVIVideoOrientationUp;
        case kCGImagePropertyOrientationLeft: return TVIVideoOrientationLeft;
        case kCGImagePropertyOrientationLeftMirrored: return TVIVideoOrientationLeft;
        case kCGImagePropertyOrientationRight: return TVIVideoOrientationRight;
        case kCGImagePropertyOrientationRightMirrored: return TVIVideoOrientationRight;
        case kCGImagePropertyOrientationDown: return TVIVideoOrientationDown;
        case kCGImagePropertyOrientationDownMirrored: return TVIVideoOrientationDown;
    }
}

@implementation TVIReplayKitVideoFrameFactory

- (TVIVideoFrame *)makeVideoFrameWithSample:(CMSampleBufferRef)sampleBuffer {
    NSParameterAssert(sampleBuffer);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if (!imageBuffer) {
        return nil;
    }

    if (CVPixelBufferGetPixelFormatType(imageBuffer) != kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        return nil;
    }
    
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    TVIVideoOrientation orientation = SampleBufferGetOrientation(sampleBuffer);
    
    return [[TVIVideoFrame alloc] initWithTimestamp:timestamp buffer:imageBuffer orientation:orientation];
}

@end
