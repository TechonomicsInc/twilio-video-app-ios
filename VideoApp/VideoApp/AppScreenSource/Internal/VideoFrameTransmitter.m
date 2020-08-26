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
@property (nonatomic, strong) dispatch_source_t timer; // Strong?

@end

@implementation VideoFrameTransmitter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _queue = dispatch_queue_create("com.twilio.video.source.screen", DISPATCH_QUEUE_SERIAL); // More unique?
        dispatch_set_target_queue(_queue, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)); // Correct QOS?
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    }
    
    return self;
}

- (void)transmitVideoFrame:(TVIVideoFrame *)videoFrame
            repeatInterval:(CMTime)repeatInterval
                      sink:(id<TVIVideoSink>)sink {
    [sink onVideoFrame:videoFrame];
    self.lastVideoFrame = videoFrame;
    self.lastTimestamp = CMClockGetTime(CMClockGetHostTimeClock());
    
    dispatch_source_cancel(self.timer);
    
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, <#uint64_t interval#>, 20);
    
    







    dispatch_resume(self.timer);
}

@end
