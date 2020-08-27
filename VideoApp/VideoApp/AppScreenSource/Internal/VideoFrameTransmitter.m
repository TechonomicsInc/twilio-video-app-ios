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
@property (nonatomic, assign) CMTime lastTimestamp;
@property (nonatomic, strong) dispatch_queue_t queue; // Strong?
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) id<TVIVideoSink> sink;

@end

@implementation VideoFrameTransmitter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create("com.twilio.video.source.screen", DISPATCH_QUEUE_SERIAL); // More unique?
        dispatch_set_target_queue(_queue, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)); // Correct QOS?
    }
    
    return self;
}

- (void)transmitVideoFrame:(TVIVideoFrame *)videoFrame
            repeatInterval:(CMTime)repeatInterval // Change
                      sink:(id<TVIVideoSink>)sink {
    NSLog(@"TCR new frame");
    [self startTimer];
    self.sink = sink;
    
    [sink onVideoFrame:videoFrame];
    self.lastVideoFrame = videoFrame;
    self.lastTimestamp = CMClockGetTime(CMClockGetHostTimeClock());
}

- (void)startTimer {
    if (self.displayLink != nil) {
        return;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timer:)];
    self.displayLink.preferredFramesPerSecond = 10;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes]; // Remove from run loop
}

- (void)timer:(CADisplayLink *)sender {
    CMTime currentTime = CMClockGetTime(CMClockGetHostTimeClock());
    CMTime delta = CMTimeSubtract(currentTime, self.lastTimestamp);
    CMTime maxInterval = CMTimeMake(100, 1000);
    
    if (CMTimeCompare(delta, maxInterval) >= 0) {
//        NSLog(@"TCR resend frame");
        TVIVideoFrame *newFrame = [[TVIVideoFrame alloc] initWithTimestamp:currentTime
                                                                    buffer:self.lastVideoFrame.imageBuffer
                                                               orientation:self.lastVideoFrame.orientation];
        
        [self.sink onVideoFrame:newFrame];
    }
}

@end
