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

@import TwilioVideo;



@interface TVIInAppScreenCapturerOptions : NSObject

@property (nonatomic, copy, nullable) NSString *trackName;

@end





@protocol TVIInAppScreenCapturerDelegate;







@interface TVIInAppScreenCapturer : NSObject

@property (nonatomic, weak, nullable) id<TVIInAppScreenCapturerDelegate> delegate;

@property (atomic, assign, readonly) BOOL isAvailable;

@property (nonatomic, copy, nullable, readonly) TVILocalVideoTrack *track;

- (nonnull instancetype)initWithOptions:(nullable TVIInAppScreenCapturerOptions *)options;

- (void)startCapture;

- (void)stopCapture;

@end







@protocol TVIInAppScreenCapturerDelegate <NSObject>

@optional

- (void)capturerDidChangeAvailability:(nonnull TVIInAppScreenCapturer *)capturer;

- (void)capturer:(nonnull TVIInAppScreenCapturer *)capturer didStartCaptureWithTrack:(nonnull TVILocalVideoTrack *)track;

- (void)capturer:(nonnull TVIInAppScreenCapturer *)capturer didFailToStartCaptureWithError:(nonnull NSError *)error;

- (void)capturer:(nonnull TVIInAppScreenCapturer *)capturer didFailToStopCaptureWithError:(nonnull NSError *)error;

@end
