//
//  SENConditionRange.h
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//

#import <Foundation/Foundation.h>
#import "SENCondition.h"

NS_ASSUME_NONNULL_BEGIN

@interface SENConditionRange : NSObject

@property (nonatomic, strong, readonly) NSNumber* minValue;
@property (nonatomic, strong, readonly) NSNumber* maxValue;
@property (nonatomic, assign, readonly) SENCondition condition;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END