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
#import <ReplayKit/ReplayKit.h>

#import "VideoApp-Swift.h"
#import "TVIAppScreenSource.h"

@interface TVIAppScreenSource()

@property (nonatomic, strong) RPScreenRecorder *screenRecorder;
@property (nonatomic, strong) ReplayKitVideoSource *source;

@end

@implementation TVIAppScreenSource

@synthesize screencast;
@synthesize sink;

- (instancetype)init {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(nullable id<TVIAppScreenSourceDelegate>)delegate {
//    TVIAppScreenSourceOptionsBuilder *builder = [[TVIAppScreenSourceOptionsBuilder alloc] initPrivate];
    TVIAppScreenSourceOptions *options; //  = [[TVIAppScreenSourceOptions alloc] initWithBuilder:builder];
    return [self initWithOptions:options delegate:delegate];
}

- (instancetype)initWithOptions:(nonnull TVIAppScreenSourceOptions *)options
                               delegate:(nullable id<TVIAppScreenSourceDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        _screenRecorder = [RPScreenRecorder sharedRecorder];
        _source = [ReplayKitVideoSource new];
        screencast = YES;
    }
    
    return self;
}

- (BOOL)isAvailable
{
    return self.screenRecorder.isAvailable;
}

- (void)startCapture {
    self.screenRecorder.microphoneEnabled = NO;
    self.screenRecorder.cameraEnabled = NO;
    
    // Prevent retain cycles
    [self.screenRecorder startCaptureWithHandler:^(CMSampleBufferRef sampleBuffer, RPSampleBufferType bufferType, NSError *error) {
        // Handle error
        
        switch (bufferType) {
            case RPSampleBufferTypeVideo:
                self.source.sink = self.sink; // Fix this
                [self.source processFrameWithSampleBuffer:sampleBuffer];
                break;
            default:
                break;
        }
    } completionHandler:^(NSError *error) {
        // Handle error
    }];
}

- (void)startCaptureWithCompletion:(nullable TVIAppScreenSourceStartedBlock)completion {
    
}

- (void)startCaptureWithFormat:(nonnull TVIVideoFormat *)format
                    completion:(nullable TVIAppScreenSourceStartedBlock)completion {
    
}

- (void)stopCapture {
    [self.screenRecorder stopCaptureWithHandler:^(NSError *error) {
        // Handle error
    }];
}

- (void)stopCaptureWithCompletion:(nullable TVIAppScreenSourceStoppedBlock)completion {
    
}

- (void)requestOutputFormat:(nonnull TVIVideoFormat *)outputFormat {

}

@end
