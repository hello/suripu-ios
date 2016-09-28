//
//  SENAPIExpansion.h
//  Pods
//
//  Created by Jimmy Lu on 9/27/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENExpansion;
@class SENExpansionConfig;

NS_ASSUME_NONNULL_BEGIN

@interface SENAPIExpansion : NSObject

+ (void)getSupportedExpansions:(SENAPIDataBlock)completion;
+ (void)getExpansionById:(NSString*)expansionId
              completion:(SENAPIDataBlock)completion;
+ (void)updateExpansionStateFor:(SENExpansion*)expansion
                     completion:(nullable SENAPIDataBlock)completion;
+ (void)getExpansionConfigurationsFor:(SENExpansion*)expansion
                           completion:(SENAPIDataBlock)completion;
+ (void)setExpansionConfiguration:(SENExpansionConfig*)config
                     forExpansion:(SENExpansion*)expansion
                       completion:(nullable SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END