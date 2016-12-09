//
//  HEMTimeZoneAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 12/10/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <SenseKit/SENService.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMTimeZoneAlertCallback)(BOOL needsTimeZone);

@interface HEMTimeZoneAlertService : SENService

- (void)checkTimeZoneSetting:(HEMTimeZoneAlertCallback)completion;

@end

NS_ASSUME_NONNULL_END
