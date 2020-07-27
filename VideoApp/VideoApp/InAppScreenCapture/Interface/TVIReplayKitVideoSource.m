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

#import <Foundation/Foundation.h>


#import "TVIReplayKitVideoSource.h"

@implementation TVIReplayKitVideoSource

@synthesize screencast;
@synthesize sink;


- (nonnull instancetype)init {
    self = [super init];
    if (self) {
        // Do init
    }
    return self;
}

//- (void)processVideoSamples:(nonnull CMSampleBuffer *)samples {
//
//}

- (void)requestOutputFormat:(nonnull TVIVideoFormat *)outputFormat {
    
}

@end
