//
//  HEMBreadcrumbService.h
//  Sense
//
//  Created by Jimmy Lu on 5/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

extern NSString* const HEMBreadcrumbSettings;
extern NSString* const HEMBreadcrumbAccount;

@class SENAccount;

@interface HEMBreadcrumbService : SENService

+ (instancetype)sharedServiceForAccount:(SENAccount*)account;
- (NSString*)peek;
- (NSString*)pop;
- (BOOL)clearIfTrailEndsAt:(NSString*)crumb;

@end
