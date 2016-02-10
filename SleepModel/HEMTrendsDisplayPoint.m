//
//  HEMTrendsDataPoint.m
//  Sense
//
//  Created by Jimmy Lu on 2/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENCondition.h>
#import "HEMTrendsDisplayPoint.h"

@interface HEMTrendsDisplayPoint()

@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, strong) NSNumber* value;

@end

@implementation HEMTrendsDisplayPoint

- (instancetype)initWithValue:(NSNumber*)value highlighted:(BOOL)highlighted {
    self = [super init];
    if (self) {
        _highlighted = highlighted;
        _value = value;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"value: %@, highlighted: %@",
            [self value], @([self highlighted])];
}

@end
