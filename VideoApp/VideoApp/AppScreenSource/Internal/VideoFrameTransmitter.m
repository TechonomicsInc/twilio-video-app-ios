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

#import "VideoFrameTransmitter.h"

@interface VideoFrameTransmitter()

@property (nonatomic, retain) TVIVideoFrame *lastVideoFrame;
//@property (nonatomic, strong) dispatch_queue_t queue; // Strong?
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) id<TVIVideoSink> sink;

@end

@implementation VideoFrameTransmitter

- (instancetype)init {
    self = [super init];
    
    if (self) {
//        _queue = dispatch_queue_create("com.twilio.video.source.screen", DISPATCH_QUEUE_SERIAL); // More unique?
//        dispatch_set_target_queue(_queue, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)); // Correct QOS?

        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timer:)];
        _displayLink.preferredFramesPerSecond = 30;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes]; // Remove from run loop
    }
    
    return self;
}

- (void)transmitVideoFrame:(TVIVideoFrame *)videoFrame sink:(id<TVIVideoSink>)sink {
    NSLog(@"Receive");
    self.sink = sink;
    self.lastVideoFrame = videoFrame;
//    [self.sink onVideoFrame:videoFrame];
}

- (void)timer:(CADisplayLink *)sender {
    if (self.lastVideoFrame == nil) {
        return;
    }
    
    CMTime currentTime = CMClockGetTime(CMClockGetHostTimeClock());
    
    TVIVideoFrame *videoFrame = [[TVIVideoFrame alloc] initWithTimestamp:currentTime
                                                             buffer:self.lastVideoFrame.imageBuffer
                                                        orientation:self.lastVideoFrame.orientation];
    
    NSLog(@"Transmit");
    [self.sink onVideoFrame:videoFrame];
}

@end
