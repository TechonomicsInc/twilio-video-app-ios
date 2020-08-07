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





@protocol TVIAppScreenSourceDelegate;





@interface TVIAppScreenSource : NSObject <TVIVideoSource>

- (nonnull instancetype)init;

- (nonnull instancetype)initWithDelegate:(nullable id<TVIAppScreenSourceDelegate>)delegate;

@property (nonatomic, weak, nullable) id<TVIAppScreenSourceDelegate> delegate;

@property (atomic, assign, readonly) BOOL isAvailable;

- (void)startCapture;

- (void)startCaptureWithFormat:(nonnull TVIVideoFormat *)format // Use completion like TVIVideoSource and ReplayKit?

- (void)stopCapture;

@end





// Test delegate to figure out what functions we need
@protocol TVIAppScreenSourceDelegate <NSObject>

@optional

- (void)appScreenSourceDidChangeAvailability:(nonnull TVIAppScreenSource *)source;

- (void)appScreenSource:(nonnull TVIAppScreenSource *)source didStartCapture;

- (void)appScreenSource:(nonnull TVIAppScreenSource *)source didFailToStartCaptureWithError:(nonnull NSError *)error; // TVIVideoFormat

- (void)appScreenSource:(nonnull TVIAppScreenSource *)source didFailToStopCaptureWithError:(nonnull NSError *)error;

@end
