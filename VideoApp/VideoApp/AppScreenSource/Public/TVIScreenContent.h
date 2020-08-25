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

/**
 *  `TVIScreenContent` specifies how `TVIAppScreenSource` should optimize the video format.
 */
typedef NS_ENUM(NSUInteger, TVIScreenContent) {
    /**
     *  Optimize video format for image sharpness and quality.
     */
    TVIScreenContentDefault = 0,
    /**
     *  Optimize video format for fluid motion.
     */
    TVIScreenContentVideo
};
