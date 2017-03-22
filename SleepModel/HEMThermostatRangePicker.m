//
//  HEMThermostatRangePicker.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UICountingLabel/UICountingLabel.h>

#import "Sense-Swift.h"
#import "NSBundle+HEMUtils.h"

#import "HEMThermostatRangePicker.h"

static CGFloat const kHEMThermostatBottomBorderWidth = 0.5f;
static NSInteger const kHEMThermostatValueSeparation = 3;
static CGFloat const kHEMThermostatDefaultMin = 0.0f;
static CGFloat const kHEMThermostatDefaultMax = 100.0f;
static CGFloat const kHEMThermostatAutoChangeDelay = 0.1f;

@interface HEMThermostatRangePicker()

@property (nonatomic, weak) UIButton* buttonBeingPressed;
@property (nonatomic, strong) UIFont* buttonFont;
@property (nonatomic, strong) UIColor* buttonBgColor;
@property (nonatomic, strong) UIColor* buttonBgPressedColor;
@property (nonatomic, strong) UIColor* buttonBgDisabledColor;
@property (nonatomic, strong) UIColor* buttonTextColor;
@property (nonatomic, strong) UIColor* buttonTextPressedColor;
@property (nonatomic, strong) UIColor* buttonTextDisabledColor;

@end

@implementation HEMThermostatRangePicker

+ (instancetype)rangePickerWithMin:(NSInteger)min
                               max:(NSInteger)max
                      withMinLimit:(CGFloat)minLimit
                          maxLimit:(CGFloat)maxLimit {
    HEMThermostatRangePicker* picker = [NSBundle loadNibWithOwner:self];
    NSInteger actualMin = min, actualMax = max;
    if (labs(actualMax - actualMin) < kHEMThermostatValueSeparation) {
        actualMin = minLimit;
        if (labs(actualMax - actualMin) < kHEMThermostatValueSeparation) {
            actualMax = actualMin + kHEMThermostatValueSeparation;
        }
    }
    [[picker minLabel] countFromZeroTo:MAX(actualMin, minLimit) withDuration:0.0f];
    [[picker maxLabel] countFromZeroTo:MIN(actualMax, maxLimit) withDuration:0.0f];
    [picker setMinLimit:minLimit];
    [picker setMaxLimit:maxLimit];
    return picker;
}

- (void)willMoveToSuperview:(nullable UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [self updateEnableStateForButtons];
    }
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
    [super awakeFromNib];
    
    UIColor* backgroundColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyBackgroundColor];
    UIColor* highlightedColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertyTextHighlightedColor];
    UIFont* highlightedFont = [SenseStyle fontWithGroup:GroupExpansionRangePicker property:ThemePropertyTextFont];
    
    [self setBackgroundColor:backgroundColor];
    
    [[self separatorLabel] setFont:highlightedFont];
    [[self separatorLabel] setTextColor:highlightedColor];
    
    [self setValueLabelDefaultsFor:[self minLabel] font:highlightedFont color:highlightedColor];
    [self setValueLabelDefaultsFor:[self maxLabel] font:highlightedFont color:highlightedColor];
    
    [self configureButtonStyles];
    [self setButtonDefaultsFor:[self increaseMinButton]];
    [self setButtonDefaultsFor:[self increaseMaxButton]];
    [self setButtonDefaultsFor:[self decreaseMinButton]];
    [self setButtonDefaultsFor:[self decreaseMaxButton]];
    
    [self setMinLimit:kHEMThermostatDefaultMin];
    [self setMaxLimit:kHEMThermostatDefaultMax];
}

- (void)configureButtonStyles {
    static NSString* fontKey = @"sense.button.font";
    static NSString* textColorKey = @"sense.button.text.color";
    static NSString* textPressedColorKey = @"sense.button.text.pressed.color";
    static NSString* textDisabledColorKey = @"sense.button.text.disabled.color";
    static NSString* bgColorKey = @"sense.button.background.color";
    static NSString* bgPressedColorKey = @"sense.button.background.pressed.color";
    static NSString* bgDisabledColorKey = @"sense.button.background.disabled.color";
    [self setButtonFont:[SenseStyle fontWithGroup:GroupExpansionRangePicker propertyName:fontKey]];
    [self setButtonTextColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:textColorKey]];
    [self setButtonTextPressedColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:textPressedColorKey]];
    [self setButtonTextDisabledColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:textDisabledColorKey]];
    [self setButtonBgColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:bgColorKey]];
    [self setButtonBgPressedColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:bgPressedColorKey]];
    [self setButtonBgDisabledColor:[SenseStyle colorWithGroup:GroupExpansionRangePicker propertyName:bgDisabledColorKey]];
}

- (void)setValueLabelDefaultsFor:(UICountingLabel*)label font:(UIFont*)font color:(UIColor*)color {
    NSString* valueFormat = NSLocalizedString(@"expansion.range.picker.value.format", nil);
    [label setFormat:valueFormat];
    [label setFont:font];
    [label setTextColor:color];
}

- (void)setButtonDefaultsFor:(UIButton*)button {
    CGRect rect = [button bounds];
    CGFloat width = CGRectGetWidth(rect);
    [[button layer] setCornerRadius:(width / 2.0f)];
    [[button layer] setMasksToBounds:YES];
    
    [button setExclusiveTouch:YES];
    [button setAdjustsImageWhenHighlighted:NO];
    [[button titleLabel] setFont:[self buttonFont]];
    [button setTitleColor:[self buttonTextColor] forState:UIControlStateNormal];
    [button setTitleColor:[self buttonTextDisabledColor] forState:UIControlStateDisabled];
    [button setBackgroundColor:[self buttonBgColor]];
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
    
    UIColor* separatorColor = [SenseStyle colorWithGroup:GroupExpansionRangePicker property:ThemePropertySeparatorColor];
    CGContextSetStrokeColorWithColor(context, [separatorColor CGColor]);
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
    [self setButton:[self increaseMinButton] enabled:currentMin != maxMinValue];
    [self setButton:[self decreaseMinButton] enabled:currentMin != [self minLimit]];
    [self setButton:[self increaseMaxButton] enabled:currentMax !=[self maxLimit]];
    [self setButton:[self decreaseMaxButton] enabled:currentMax != minMaxValue];
}

- (void)setButton:(UIButton*)button enabled:(BOOL)enabled {
    [button setEnabled:enabled];
    if (enabled) {
        [button setBackgroundColor:[self buttonBgColor]];
    } else {
        [button setBackgroundColor:[self buttonBgDisabledColor]];
    }
}

#pragma mark - Touches

- (void)touchDownOnButton:(UIButton*)button {
    [self setButtonBeingPressed:button];
    if ([button isEnabled]) {
        [button setBackgroundColor:[self buttonBgPressedColor]];
    }
    [button setTitleColor:[self buttonTextPressedColor] forState:UIControlStateNormal];
    [self rollingValue];
}

- (void)touchDownUpButton:(UIButton*)button {
    [self setButtonBeingPressed:nil];
    if ([button isEnabled]) {
        [button setBackgroundColor:[self buttonBgColor]];
    }
    [button setTitleColor:[self buttonTextColor] forState:UIControlStateNormal];
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
