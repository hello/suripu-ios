//
//  HEMMixpanelProvider.h
//  Sense
//
//  Created by Jimmy Lu on 11/25/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SENAnalyticsProvider.h"

@interface HEMMixpanelProvider : NSObject <SENAnalyticsProvider>

- (nonnull instancetype)initWithToken:(nonnull NSString*)token NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@end
