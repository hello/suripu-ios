//
//  HEMAudioService.h
//  Sense
//
//  Created by Jimmy Lu on 4/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMAudioServiceErrorDomain;

typedef NS_ENUM(NSInteger, HEMAudioServiceError) {
    HEMAudioServiceErrorInvalidURL = -1
};

typedef void(^HEMAudioActivationHandler)(NSError* _Nullable error);
typedef void(^HEMAudioDownloadHandler)(NSData* _Nullable soundData, NSError* _Nullable error);

@interface HEMAudioService : SENService

/**
 * https://developer.apple.com/library/ios/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/ConfiguringanAudioSession/ConfiguringanAudioSession.html
 *
 * "Most apps never need to deactivate their audio session explicitly. Important
 * exceptions include VoIP (Voice over Internet Protocol) apps, turn-by-turn
 * navigation apps, and, in some cases, recording apps."
 *
 * If deactivating the session, be sure to make sure audio is stopped and not
 * paused before doing so.  If not verified before deactivating, an error will
 * occur and a hiccup in the main thread will occur.
 *
 * @param activate: YES, to activate.  NO otherwise
 * @param completion: the callback to use when session has been activated or deactivated
 */
- (void)activateSession:(BOOL)activate completion:(nullable HEMAudioActivationHandler)completion;

/**
 * @discussion
 * This does not do any type of filtering to ensure the file downloaded is an
 * audio file.  It acts as a simple downloader and returns the data from the file
 * if all succeeds.
 *
 * @param urlString: the url to the remote sound file
 * @completion: the callback to call after the file data has been downloaded
 */
- (void)downloadAudioFileWithURL:(NSString*)urlString completion:(HEMAudioDownloadHandler)completion;

@end

NS_ASSUME_NONNULL_END