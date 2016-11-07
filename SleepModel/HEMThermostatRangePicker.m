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
static CGFloat const kHEMThermostatDefaultMin = 0.0f;
static CGFloat const kHEMThermostatDefaultMax = 100.0f;
static CGFloat const kHEMThermostatAutoChangeDelay = 0.2f;

@interface HEMThermostatRangePicker()

@property (nonatomic, weak) UIButton* buttonBeingPressed;

@end

@implementation HEMThermostatRangePicker

+ (instancetype)rangePickerWithMin:(NSInteger)min max:(NSInteger)max {
    HEMThermostatRangePicker* picker = [NSBundle loadNibWithOwner:self];
    [[picker minLabel] countFromZeroTo:MAX(min, [picker minLimit]) withDuration:0.0f];
    [[picker maxLabel] countFromZeroTo:MIN(max, [picker maxLimit]) withDuration:0.0f];
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
    
//    [[self increaseMinButton] addTarget:self
//                                 action:@selector(incrementMin)
//                       forControlEvents:UIControlEventTouchUpInside];
//    [[self decreaseMinButton] addTarget:self
//                                 action:@selector(decrementMin)
//                       forControlEvents:UIControlEventTouchUpInside];
//    [[self increaseMaxButton] addTarget:self
//                                 action:@selector(incrementMax)
//                       forControlEvents:UIControlEventTouchUpInside];
//    [[self decreaseMaxButton] addTarget:self
//                                 action:@selector(decrementMax)
//                       forControlEvents:UIControlEventTouchUpInside];
    
    [self setMinLimit:kHEMThermostatDefaultMin];
    [self setMaxLimit:kHEMThermostatDefaultMax];
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
    
    [button setExclusiveTouch:YES];
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

#pragma mark - Button States

- (void)updateEnableStateForButtons {
    CGFloat currentMin = [[self minLabel] currentValue];
    CGFloat currentMax = [[self maxLabel] currentValue];
    CGFloat maxMinValue = [self maxLimit] - kHEMThermostatValueSeparation;
    CGFloat minMaxValue = [self minLimit] + kHEMThermostatValueSeparation;
    [[self increaseMinButton] setEnabled:currentMin != maxMinValue];
    [[self decreaseMinButton] setEnabled:currentMin != [self minLimit]];
    [[self increaseMaxButton] setEnabled:currentMax !=[self maxLimit]];
    [[self decreaseMaxButton] setEnabled:currentMax != minMaxValue];
}

#pragma mark - Touches

- (void)touchDownOnButton:(UIButton*)button {
    [self setButtonBeingPressed:button];
    [button setBackgroundColor:[UIColor blue6]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self rollingValue];
}

- (void)touchDownUpButton:(UIButton*)button {
    [self setButtonBeingPressed:nil];
    [button setBackgroundColor:[UIColor blue2]];
    [button setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)rollingValue {
    if ([self buttonBeingPressed] == [self increaseMinButton]) {
        [self incrementMin];
    } else if ([self buttonBeingPressed] == [self increaseMaxButton]) {
        [self incrementMax];
    } else if ([self buttonBeingPressed] == [self decreaseMinButton]) {
        [self decrementMin];
    } else if ([self buttonBeingPressed] == [self decreaseMaxButton]) {
        [self decrementMax];
    }
    
    if ([self buttonBeingPressed]) {
        __weak typeof(self) weakSelf = self;
        int64_t delayInSecs = (int64_t)(kHEMThermostatAutoChangeDelay * NSEC_PER_SEC);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf rollingValue];
        });
    }
}

- (void)updateLabel:(UICountingLabel*)label
            toValue:(CGFloat)value
       withDuration:(NSTimeInterval)duration {
    
    CGFloat valueToShow = value;
    
    if (label == [self minLabel]) {
        CGFloat maxMinValue = [self maxLimit] - kHEMThermostatValueSeparation;
        valueToShow = MIN(MAX(value, [self minLimit]), maxMinValue);
        if (valueToShow > [[self maxLabel] currentValue] - kHEMThermostatValueSeparation) {
            NSInteger autoMax = valueToShow + kHEMThermostatValueSeparation;
            [self updateLabel:[self maxLabel] toValue:autoMax withDuration:0.0f];
        }
    } else {
        CGFloat minMaxValue = [self minLimit] + kHEMThermostatValueSeparation;
        valueToShow = MAX(MIN(value, [self maxLimit]), minMaxValue);
        if (valueToShow < [[self minLabel] currentValue] + kHEMThermostatValueSeparation) {
            NSInteger autoMin = valueToShow - kHEMThermostatValueSeparation;
            [self updateLabel:[self minLabel] toValue:autoMin withDuration:0.0f];
        }
    }
    
    [label countFromCurrentValueTo:valueToShow withDuration:duration];
    [self updateEnableStateForButtons];
}

- (void)incrementMin {
    CGFloat next = [[self minLabel] currentValue] + 1;
    [self updateLabel:[self minLabel] toValue:next withDuration:0.0f];
}

- (void)incrementMax {
    CGFloat next = [[self maxLabel] currentValue] + 1;
    [self updateLabel:[self maxLabel] toValue:next withDuration:0.0f];
}

- (void)decrementMin {
    CGFloat next = [[self minLabel] currentValue] - 1;
    [self updateLabel:[self minLabel] toValue:next withDuration:0.0f];
}

- (void)decrementMax {
    CGFloat next = [[self maxLabel] currentValue] - 1;
    [self updateLabel:[self maxLabel] toValue:next withDuration:0.0f];
}

@end
