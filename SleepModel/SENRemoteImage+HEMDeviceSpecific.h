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

- (NSString*)uriForCurrentDevice;

@end

NS_ASSUME_NONNULL_END
