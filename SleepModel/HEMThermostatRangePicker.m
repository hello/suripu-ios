//
//  HEMThermostatRangePicker.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UICountingLabel/UICountingLabel.h>

#import "NSBundle+HEMUtils.h"

#import "HEMThermostatRangePicker.h"
#import "HEMStyle.h"

static CGFloat const kHEMThermostatBottomBorderWidth = 0.5f;
static NSInteger const kHEMThermostatValueSeparation = 3;
static NSTimeInterval const kHEMThermostatValueAutoAdjustDuration = 0.5f;

@implementation HEMThermostatRangePicker

+ (instancetype)rangePickerWithMin:(NSInteger)min max:(NSInteger)max {
    HEMThermostatRangePicker* picker = [NSBundle loadNibWithOwner:self];
    [[picker minLabel] countFromZeroTo:min withDuration:0.0f];
    [[picker maxLabel] countFromZeroTo:max withDuration:0.0f];
    return picker;
}

- (UIImage *)imageWithColor:(UIColor *)color forRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)awakeFromNib {
    [[self separatorLabel] setFont:[UIFont alarmSelectedNumberFont]];
    [[self separatorLabel] setTextColor:[UIColor tintColor]];
    
    [self setValueLabelDefaultsFor:[self minLabel]];
    [self setValueLabelDefaultsFor:[self maxLabel]];
    
    [self setButtonDefaultsFor:[self increaseMinButton]];
    [self setButtonDefaultsFor:[self increaseMaxButton]];
    [self setButtonDefaultsFor:[self decreaseMinButton]];
    [self setButtonDefaultsFor:[self decreaseMaxButton]];
    
    [[self increaseMinButton] addTarget:self
                                 action:@selector(incrementMin)
                       forControlEvents:UIControlEventTouchUpInside];
    [[self decreaseMinButton] addTarget:self
                                 action:@selector(decrementMin)
                       forControlEvents:UIControlEventTouchUpInside];
    [[self increaseMaxButton] addTarget:self
                                 action:@selector(incrementMax)
                       forControlEvents:UIControlEventTouchUpInside];
    [[self decreaseMaxButton] addTarget:self
                                 action:@selector(decrementMax)
                       forControlEvents:UIControlEventTouchUpInside];
}

- (void)setValueLabelDefaultsFor:(UICountingLabel*)label {
    NSString* valueFormat = NSLocalizedString(@"expansion.range.picker.value.format", nil);
    [label setFormat:valueFormat];
    [label setFont:[UIFont alarmSelectedNumberFont]];
    [label setTextColor:[UIColor tintColor]];
}

- (void)setButtonDefaultsFor:(UIButton*)button {
    CGRect rect = [button bounds];
    CGFloat width = CGRectGetWidth(rect);
    [[button layer] setCornerRadius:(width / 2.0f)];
    [[button layer] setMasksToBounds:YES];
    
    [button setAdjustsImageWhenHighlighted:NO];
    [[button titleLabel] setFont:[UIFont buttonLarge]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blue2]];
    [button addTarget:self
               action:@selector(touchDownOnButton:)
     forControlEvents:UIControlEventTouchDown];
    [button addTarget:self
               action:@selector(touchDownUpButton:)
     forControlEvents:(UIControlEventTouchUpInside
                       | UIControlEventTouchUpOutside
                       | UIControlEventTouchCancel
                       | UIControlEventTouchDragOutside)];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [[UIColor separatorColor] CGColor]);
    CGContextSetLineWidth(context, kHEMThermostatBottomBorderWidth);
    
    CGFloat y = CGRectGetHeight([self bounds]) - kHEMThermostatBottomBorderWidth;
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

#pragma mark - Touches

- (void)touchDownOnButton:(UIButton*)button {
    [button setBackgroundColor:[UIColor blue6]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)touchDownUpButton:(UIButton*)button {
    [button setBackgroundColor:[UIColor blue2]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (CGFloat)updateLabel:(UICountingLabel*)label
                    by:(NSInteger)diff
          withDuration:(NSTimeInterval)duration {
    CGFloat next = [label currentValue] + diff;
    [label countFromCurrentValueTo:next withDuration:duration];
    return next;
}

// TODO: handle min and max values
// TODO: disable buttons as needed based on min + max
- (void)adjustMaxIfNeededFromMinValue:(CGFloat)min {
    if (min == [[self maxLabel] currentValue]) {
        [self updateLabel:[self maxLabel]
                       by:kHEMThermostatValueSeparation
             withDuration:kHEMThermostatValueAutoAdjustDuration];
    }
}

- (void)adjustMinIfNeededFromMaxValue:(CGFloat)max {
    if (max == [[self minLabel] currentValue]) {
        [self updateLabel:[self minLabel]
                       by:-kHEMThermostatValueSeparation
             withDuration:kHEMThermostatValueAutoAdjustDuration];
    }
}

- (void)incrementMin {
    CGFloat value = [self updateLabel:[self minLabel] by:1 withDuration:0.0f];
    [self adjustMaxIfNeededFromMinValue:value];
}

- (void)incrementMax {
    CGFloat value = [self updateLabel:[self maxLabel] by:1 withDuration:0.0f];
    [self adjustMinIfNeededFromMaxValue:value];
}

- (void)decrementMin {
    CGFloat value = [self updateLabel:[self minLabel] by:-1 withDuration:0.0f];
    [self adjustMaxIfNeededFromMinValue:value];
}

- (void)decrementMax {
    CGFloat value = [self updateLabel:[self maxLabel] by:-1 withDuration:0.0f];
    [self adjustMinIfNeededFromMaxValue:value];
}

@end
