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

#import "TVIScreenContent.h"

/**
 *  `TVIAppScreenSourceOptionsBuilder` is a builder class for `TVIAppScreenSourceOptions`.
 */
@interface TVIAppScreenSourceOptionsBuilder : NSObject

/**
 *  @brief How `TVIAppScreenSource` should optimize the video format.
 *
 *  @see TVIScreenContent
 */
@property (nonatomic, assign) TVIScreenContent screenContent;

/**
 *  @brief You should not initialize `TVIAppScreenSourceOptionsBuilder` directly, use a `TVIAppScreenSourceOptionsBuilderBlock` instead.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use a TVIAppScreenSourceOptionsBuilderBlock instead.")));

@end

/**
 *  `TVIAppScreenSourceOptionsBuilderBlock` allows you to construct `TVIAppScreenSourceOptions` using the builder pattern.
 *
 *  @param builder The builder.
 */
typedef void (^TVIAppScreenSourceOptionsBuilderBlock)(TVIAppScreenSourceOptionsBuilder * _Nonnull builder);

/**
 *  Represents immutable configuration options for a `TVIAppScreenSource`.
 */
@interface TVIAppScreenSourceOptions : NSObject

/**
 *  @brief How `TVIAppScreenSource` should optimize the video format. Defaults to `TVIScreenContentDefault`.
 *
 *  @see TVIScreenContent
 */
@property (nonatomic, assign, readonly) TVIScreenContent screenContent;

/**
 *  @brief Developers shouldn't initialize this class directly.
 *
 *  @discussion Use the class method `optionsWithBlock:` instead.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("Use optionsWithBlock: to create a TVIAppScreenSourceOptions instance.")));

/**
 *  @brief Creates an instance of `TVIAppScreenSourceOptions` using a builder block.
 *
 *  @param block The builder block which will be used to configure the `TVIAppScreenSourceOptions` instance.
 *
 *  @return An instance of `TVIAppScreenSourceOptions`.
 */
+ (nonnull instancetype)optionsWithBlock:(nonnull TVIAppScreenSourceOptionsBuilderBlock)block;

@end
