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

#import "TVIVideoFrameTransmitter.h"

@interface TVIVideoFrameTransmitter()

@property (nonatomic, retain) id<TVIVideoSink> sink;
@property (nonatomic, retain) TVIVideoFrame *videoFrame;
@property (nonatomic, retain) CADisplayLink *displayLink;

@end

@implementation TVIVideoFrameTransmitter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timer:)];
        _displayLink.preferredFramesPerSecond = 30;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
}

- (void)transmitVideoFrame:(TVIVideoFrame *)videoFrame sink:(id<TVIVideoSink>)sink {
    NSParameterAssert(videoFrame);
    NSParameterAssert(sink);
    
    self.sink = sink;
    self.videoFrame = videoFrame;
}

- (void)timer:(CADisplayLink *)sender {
    if (!self.videoFrame) {
        return;
    }

    CMTime currentTime = CMClockGetTime(CMClockGetHostTimeClock());

    TVIVideoFrame *videoFrame = [[TVIVideoFrame alloc] initWithTimestamp:currentTime
                                                                  buffer:self.videoFrame.imageBuffer
                                                             orientation:self.videoFrame.orientation];
    
    [self.sink onVideoFrame:videoFrame];
}

@end
