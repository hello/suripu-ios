//
//  HEMWhatsNewService.h
//  Sense
//
//  Created by Jimmy Lu on 6/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "SENService.h"

typedef NS_ENUM(NSUInteger, HEMWhatsNewLocation) {
    HEMWhatsNewLocationNone,
    HEMWhatsNewLocationSettings
};

@interface HEMWhatsNewService : SENService

+ (void)forceToShow;

- (BOOL)shouldShow;
- (void)dismiss;
- (NSString*)title;
- (NSString*)message;
- (NSString*)buttonTitle;
- (HEMWhatsNewLocation)location;

@end
