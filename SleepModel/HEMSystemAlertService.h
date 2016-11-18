//
//  HEMSystemAlertService.h
//  Sense
//
//  Created by Jimmy Lu on 11/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>

@class SENSystemAlert;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMSystemAlertHandler)(SENSystemAlert* _Nullable alert, NSError* _Nullable error);

@interface HEMSystemAlertService : SENService

- (void)getNextAvailableAlert:(HEMSystemAlertHandler)completion;

@end

NS_ASSUME_NONNULL_END