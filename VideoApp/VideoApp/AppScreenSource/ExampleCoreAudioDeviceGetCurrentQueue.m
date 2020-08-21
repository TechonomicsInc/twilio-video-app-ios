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

dispatch_queue_t ExampleCoreAudioDeviceGetCurrentQueue() {
    /*
     * The current dispatch queue is needed in order to synchronize with samples delivered by ReplayKit. Ideally, the
     * ReplayKit APIs would support this use case, but since they do not we use a deprecated API to discover the queue.
     * The dispatch queue is used for both resource teardown, and to schedule retransmissions (when enabled).
     */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    return dispatch_get_current_queue();
#pragma clang diagnostic pop
}
