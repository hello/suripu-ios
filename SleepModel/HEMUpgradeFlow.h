//
//  HEMUpgradeFlow.h
//  Sense
//
//  Created by Jimmy Lu on 8/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEMOnboardingFlow.h"

NS_ASSUME_NONNULL_BEGIN

@interface HEMUpgradeFlow : NSObject <HEMSetupFlow>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCurrentSenseId:(NSString*)currentSenseId NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END