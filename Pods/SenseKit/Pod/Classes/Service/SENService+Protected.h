//
//  SENService+Protected.h
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//

#import "SENService.h"

@interface SENService (Protected)

/**
 * Subclasses should override this method to take action when service
 * has become active, whether that is on launch or from background to
 * foreground
 */
- (void)serviceBecameActive;

/**
 * Subclasses should override this method to take action when service
 * will soon be entering the background
 */
- (void)serviceWillBecomeInactive;

/**
 * Subclasses can optionally override this to receive such event and
 * blow away any cache that can be easily recreated.
 */
- (void)serviceReceivedMemoryWarning;

/**
 * Subclasses can call this instead of always checking if block exists before
 * proceeding to call the block with the error
 */
- (void)callIfSafe:(void(^)(NSError* error))block withError:(NSError*)error;

@end