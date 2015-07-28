//
//  HEMWaveform.m
//  Sense
//
//  Created by Delisa Mason on 7/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMWaveform.h"

@interface HEMWaveform ()
@property (nonatomic, readwrite) CGFloat minValue;
@property (nonatomic, readwrite) CGFloat maxValue;
@property (nonatomic, readwrite) NSArray *values;
@end

NSArray *validatedWaveformValues(NSArray *values) {
    if (![values isKindOfClass:[NSArray class]])
        return 0;
    NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:values.count];
    for (id value in values) {
        if ([value isKindOfClass:[NSNumber class]]) {
            [numbers addObject:value];
        }
    }
    return numbers;
}

@implementation HEMWaveform

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSString *const HEMWaveformMaxKey = @"max";
    NSString *const HEMWaveformMinKey = @"min";
    NSString *const HEMWaveformValuesKey = @"values";
    if (self = [super init]) {
        _maxValue = [dict[HEMWaveformMaxKey] floatValue];
        _minValue = [dict[HEMWaveformMinKey] floatValue];
        _values = validatedWaveformValues(dict[HEMWaveformValuesKey]);
    }
    return self;
}

- (UIImage *)waveformImageWithColor:(UIColor *)barColor height:(CGFloat)height {
    CGFloat const HEMWaveformBarSpace = 1.f;
    CGFloat const HEMWaveformBarWidth = 2.f;
    CGFloat x = 0;
    CGFloat width = HEMWaveformBarWidth * self.values.count + ((self.values.count - 1) * HEMWaveformBarSpace);
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, barColor.CGColor);
    for (NSNumber *value in self.values) {
        CGFloat barHeight = height * ([value floatValue] / self.maxValue);
        CGFloat y = height - barHeight;
        CGContextFillRect(ctx, CGRectMake(x, y, HEMWaveformBarWidth, barHeight));
        x += HEMWaveformBarSpace;
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
