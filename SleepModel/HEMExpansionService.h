//
//  HEMExpansionService.h
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SenseKit.h>

@class SENExpansion;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMExpansionListHandler)(NSArray<SENExpansion*>* _Nullable expansions, NSError* _Nullable error);

@interface HEMExpansionService : SENService

@property (nonatomic, strong, readonly) NSArray<SENExpansion*>* expansions;

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware;
- (void)getListOfExpansion:(HEMExpansionListHandler)completion;

@end

NS_ASSUME_NONNULL_END