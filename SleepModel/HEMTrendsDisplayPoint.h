//
//  HEMTrendsDataPoint.h
//  Sense
//
//  Created by Jimmy Lu on 2/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMTrendsDisplayPoint : NSObject

@property (nonatomic, assign, readonly) BOOL highlighted;
@property (nonatomic, strong, readonly) NSNumber* value;

- (instancetype)initWithValue:(NSNumber*)value highlighted:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END