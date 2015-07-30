//
//  HEMWaveform.h
//  Sense
//
//  Created by Delisa Mason on 7/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMWaveform : NSObject

@property (nonatomic, readonly) CGFloat minValue;
@property (nonatomic, readonly) CGFloat maxValue;
@property (nonatomic, readonly) NSArray *values;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 *  Create an image representing this waveform
 *
 *  @param barColor color of the bars representing intensity
 *
 *  @return an image
 */
- (UIImage *)waveformImageWithColor:(UIColor *)barColor;
@end
