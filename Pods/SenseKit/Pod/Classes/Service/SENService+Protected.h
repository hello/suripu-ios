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

@end