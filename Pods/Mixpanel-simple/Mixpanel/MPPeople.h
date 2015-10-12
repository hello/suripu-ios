//
//  MPPeople.h
//  Mixpanel
//
//  Created by Delisa Mason on 9/25/15.
//  Copyright © 2015 DeskConnect. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPDataPropagator.h"

@interface MPPeople : MPDataPropagator

- (void)setUserProperties:(NSDictionary *)properties;
@end
