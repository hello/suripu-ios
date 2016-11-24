//
//  SENRemoteImage+HEMDeviceSpecific.h
//  Sense
//
//  Created by Jimmy Lu on 12/3/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENRemoteImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface SENRemoteImage (HEMDeviceSpecific)

- (nullable NSString*)uriForCurrentDevice;

/**
 * @discussion
 * Note that this method is doing I/O from whatever thread it is on, which is
 * usually the main thread, which is typically a no-no.
 *
 * @return cached image, if any
 */
- (UIImage*)locallyCachedImageForCurrentDevice;

@end

NS_ASSUME_NONNULL_END
