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

#import "TVIAppScreenSourceOptions.h"

@protocol TVIAppScreenSourceDelegate;

/**
 *  A block called when your request to start a `TVIAppScreenSource` has completed.
 *
 *  @param format The format that you requested, or the default format selected on your behalf.
 *  @param error An error if the request to start or select could not be completed.
 */
typedef void (^TVIAppScreenSourceStartedBlock)(TVIVideoFormat * _Nonnull format,
                                               NSError * _Nullable error);

/**
 *  A block called when your request to stop a `TVIAppScreenSource` has completed.
 *
 *  @param error An error if the request to stop could not be completed.
 */
typedef void (^TVIAppScreenSourceStoppedBlock)(NSError * _Nullable error);

/**
 *  `TVIAppScreenSource` is a `TVIVideoSource` that allows you to stream video of the app screen. This
 *  class manages a `RPScreenRecorder` internally.
 */
@interface TVIAppScreenSource : NSObject <TVIVideoSource>

/**
 *  @brief Initializes a `TVIAppScreenSource`. You may set a delegate later if you wish.
 *
 *  @return A `TVIAppScreenSource`.
 */
- (nonnull instancetype)init;

/**
 *  @brief Initializes a `TVIAppScreenSource` with a delegate.
 *
 *  @param delegate A delegate conforming to `TVIAppScreenSourceDelegate`, or nil.
 *
 *  @return A `TVIAppScreenSource`.
 */
- (nonnull instancetype)initWithDelegate:(nullable id<TVIAppScreenSourceDelegate>)delegate;

/**
 *  @brief Initializes a `TVIAppScreenSource` with all configuration options. This is the designated initializer.
 *
 *  @param options A `TVIAppScreenSourceOptions` instance to configure your source.
 *  @param delegate A delegate conforming to `TVIAppScreenSourceDelegate`, or `nil`.
 *
 *  @return A `TVIAppScreenSource`.
 */
- (nonnull instancetype)initWithOptions:(nonnull TVIAppScreenSourceOptions *)options
                               delegate:(nullable id<TVIAppScreenSourceDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 *  @brief The source's delegate.
 */
@property (nonatomic, weak, nullable) id<TVIAppScreenSourceDelegate> delegate;

/**
 *  @brief Indicates whether the screen is available for capture.
 *
 *  @discussion When set to `YES`, the screen is available for capture. Screen capture can be unavailable due to unsupported
 *  hardware, the user’s device displaying information over AirPlay or through a TVOut session, or another app using ReplayKit.
 */
@property (atomic, assign, readonly) BOOL isAvailable;

/**
 *  @brief Starts capture. The video pipeline will start asynchronously after this method returns.
 *
 *  @discussion This method will automatically choose a format that works well for screen capture.
 *
 *  @note When you are done capturing video using the `TVIAppScreenSource` you must call either `[TVIAppScreenSource stopCapture]`
 *  or `[TVIAppScreenSource stopCaptureWithCompletion:]`.
 *
 *  @see stopCapture
 *  @see stopCaptureWithCompletion:
 */
- (void)startCapture;

/**
 *  @brief Starts capture with a completion handler.
 *
 *  @param completion A handler block to be called on the main thread once capture has started, or failed to start.
 *
 *  @discussion This method will automatically choose a format that works well for screen capture.
 *
 *  @note When you are done capturing video using the `TVIAppScreenSource` you must call either `[TVIAppScreenSource stopCapture]`
 *  or `[TVIAppScreenSource stopCaptureWithCompletion:]`.
 *
 *  @see stopCapture
 *  @see stopCaptureWithCompletion:
 */
- (void)startCaptureWithCompletion:(nullable TVIAppScreenSourceStartedBlock)completion;

/**
 *  @brief Stops capture asynchronously.
 *
 *  @discussion This method is equivalent to calling `[TVIAppScreenSource stopCaptureWithCompletion:]` with a nil block.
 */
- (void)stopCapture;

/**
 *  @brief Stops capture asynchronously with a completion handler.
 *
 *  @param completion A handler block to be called on the main thread once the RPScreenRecorder is stopped.
 *
 *  @discussion Use this method to coordinate your application logic with the stopping of the source's video pipeline.
 */
- (void)stopCaptureWithCompletion:(nullable TVIAppScreenSourceStoppedBlock)completion;

@end

/**
 *  `TVIAppScreenSourceDelegate` receives important lifecycle events related to `TVIAppScreenSource`.
 *  By implementing these methods you can handle state changes and errors that may occur.
 */
@protocol TVIAppScreenSourceDelegate <NSObject>

@optional

/**
 *  @brief Screen capture has become available.
 *
 *  @discussion You may wish to enable your `TVILocalVideoTrack` if you disabled it when the the source was unavailable.
 *
 *  @param source The source that has become available.
 */
- (void)appScreenSourceDidBecomeAvailable:(nonnull TVIAppScreenSource *)source;

/**
 *  @brief Screen capture has become unavailable.
 *
 *  @discussion You may wish to disable your `TVILocalVideoTrack`, and update your UI when screen capture is unavailable.
 *
 *  @param source The source that has become unavailable.
 */
- (void)appScreenSourceDidBecomeUnavailable:(nonnull TVIAppScreenSource *)source;

/**
 *  @brief The source stopped running with a fatal error.
 *
 *  @param source The source which stopped.
 *  @param error  The error which caused the source to stop.
 */
- (void)appScreenSource:(nonnull TVIAppScreenSource *)source
       didFailWithError:(nonnull NSError *)error;

@end
