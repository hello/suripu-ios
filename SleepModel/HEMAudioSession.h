//
//  HEMAudioSession.h
//  Sense
//
//  Created by Delisa Mason on 8/7/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

/**
 *  Create a shared audio session
 */
void HEMInitializeAudioSession();

/**
 * Activate / deactivate audio session asynchronously since
 * setActivate:withOptions:error is a blocking call that can
 * potentially take a little bit of time.
 *
 * @discussion Changing the activation state can potentially
 * cause an exception. All currently playing audio players
 * must be stopped first.
 *
 * @param activate YES to activate, NO otherwise
 */
void HEMActivateAudioSession(BOOL activate, void (^completion)(NSError *error));