//
//  SENTrends.h
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SENTrendsGraph;

@interface SENTrends : NSObject

@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber*>* availableTimeScales;
@property (nonatomic, strong, readonly, nullable) NSArray<SENTrendsGraph*>* graphs;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END