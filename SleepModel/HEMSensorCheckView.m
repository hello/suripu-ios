
//
//  HEMSensorCheckView.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMSensorCheckView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"
#import "HEMActivityIndicatorView.h"
#import "HEMAnimationUtils.h"

CGFloat const HEMSensorCheckCollapsedHeight = 45.0f;

static CGFloat const HEMSensorCheckHorzPadding = 45.0f;
static CGFloat const HEMSensorCheckLabelTopMargin = 20.0f;
static CGFloat const HEMSensorCheckTitleHeight = 20.0f;
static CGFloat const HEMSensorCheckMessageMaxHeight = 58.0f;
static CGFloat const HEMSensorCheckSeparatorHeight = 0.5f;
static CGFloat const HEMSensorCheckContentAnimationDuration = 0.7f;
static CGFloat const HEMSensorCheckValueDigitWidth = 45.0f;
static CGFloat const HEMSensorCheckValueDigitHeight = 110.0f;
static CGFloat const HEMSensorCheckValueUnitHeight = 20.0f;
static CGFloat const HEMSensorCheckValueUnitTopMargin = 18.0f;
static CGFloat const HEMSensorCheckPickerHeight = 162.0f;
static CGFloat const HEMSensorCheckActivitySize = 35.0f;
static CGFloat const HEMSensorCheckActivityDuration = 2.0f;
static CGFloat const HEMSensorCheckDigitDisplayDelay = 0.3f;

@interface HEMSensorCheckView() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak)   UIImageView* iconImageView;
@property (nonatomic, weak)   UILabel* titleLabel;
@property (nonatomic, weak)   UILabel* messageLabel;
@property (nonatomic, weak)   UILabel* valueLabel;
@property (nonatomic, weak)   UIView* separator;
@property (nonatomic, weak)   UIPickerView* valueView;
@property (nonatomic, weak)   HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak)   UILabel* unitLabel;
@property (nonatomic, copy)   NSString* sensorValueString;
@property (nonatomic, strong) UIColor* conditionColor;
@property (nonatomic, copy)   NSAttributedString* sensorMessage;
@property (nonatomic, copy)   NSString* introMessage;
@property (nonatomic, copy)   NSString* sensorValueUnit;

@end

@implementation HEMSensorCheckView

+ (CGFloat)collapsedHeight {
    return HEMSensorCheckCollapsedHeight;
}

- (instancetype)initWithIcon:(UIImage*)icon
             highlightedIcon:(UIImage*)highlighedIcon
                       title:(NSString*)title
                     message:(NSAttributedString*)message
                introMessage:(NSString*)intro
                       value:(NSInteger)value
          withConditionColor:(UIColor*)color
                        unit:(NSString*)unit {
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectZero;
    frame.size.height = HEMSensorCheckCollapsedHeight;
    frame.size.width = CGRectGetWidth(bounds);
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setClipsToBounds:YES];
        [self setIntroMessage:intro];
        [self setSensorMessage:message];
        [self setConditionColor:color];
        [self setSensorValueString:[NSString stringWithFormat:@"%ld", (long)value]];
        [self setSensorValueUnit:unit];
        
        [self addIconImageViewWithIcon:icon highlightedIcon:highlighedIcon];
        [self addTitleWithText:title];
        [self addMessage];
        [self addSeparator];
    }
    return self;
}

- (void)addIconImageViewWithIcon:(UIImage*)icon highlightedIcon:(UIImage*)highlightedIcon {
    UIImageView* imageView = [[UIImageView alloc] initWithImage:icon];
    [imageView setHighlightedImage:highlightedIcon];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
    
    CGRect imageFrame = [imageView frame];
    imageFrame.size = [icon size];
    imageFrame.origin.x = (CGRectGetWidth([self bounds]) - CGRectGetWidth(imageFrame))/2;
    imageFrame.origin.y = ((CGRectGetHeight([self bounds]) - CGRectGetHeight(imageFrame))/2);
    [imageView setFrame:imageFrame];
    
    [self addSubview:imageView];
    [self setIconImageView:imageView];
}

- (void)addTitleWithText:(NSString*)title {
    CGRect frame = {
        HEMSensorCheckHorzPadding,
        CGRectGetMaxY([[self iconImageView] frame]) + HEMSensorCheckLabelTopMargin,
        CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding),
        HEMSensorCheckTitleHeight
    };
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    [label setTextColor:[HelloStyleKit senseBlueColor]];
    [label setText:[title uppercaseString]];
    [label setNumberOfLines:1];
    [label setAlpha:0.0f];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont onboardingRoomCheckSensorFont]];
    
    [self addSubview:label];
    [self setTitleLabel:label];
}

- (void)addMessage {
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];

    NSAttributedString* attributedIntro =
        [[NSAttributedString alloc] initWithString:[self introMessage]
                                        attributes:@{NSFontAttributeName : [UIFont onboardingRoomCheckSensorFont],
                                                     NSForegroundColorAttributeName : [UIColor blackColor],
                                                     NSParagraphStyleAttributeName : paragraphStyle}];
    
    UILabel* label = [[UILabel alloc] init];
    [label setAttributedText:attributedIntro];
    [label setNumberOfLines:3];
    [label setAlpha:0.0f];
    
    CGFloat width = CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding);
    CGSize constraint = CGSizeZero;
    constraint.width = width;
    constraint.height = HEMSensorCheckMessageMaxHeight;

    CGRect frame = {
        HEMSensorCheckHorzPadding,
        CGRectGetMaxY([[self titleLabel] frame]) + HEMSensorCheckLabelTopMargin,
        CGRectGetWidth([self bounds]) - (2*HEMSensorCheckHorzPadding),
        [label sizeThatFits:constraint].height
    };
    [label setFrame:frame];
    
    [self addSubview:label];
    [self setMessageLabel:label];
}

- (void)showSensorValue:(void(^)(void))completion {
    NSInteger digits = [[self sensorValueString] length];
    CGFloat bWidth = CGRectGetWidth([self bounds]);
    CGFloat lastY = CGRectGetMaxY([[self messageLabel] frame]);
    CGFloat spaceLeft = CGRectGetHeight([self bounds]) - lastY;
    CGFloat width = digits*(HEMSensorCheckValueDigitWidth + 15.0f);
    CGRect frame = {
        (bWidth - width)/2,
        (lastY + (spaceLeft - HEMSensorCheckPickerHeight)/2),
        width,
        HEMSensorCheckPickerHeight
    };
    UIPickerView* digitPicker = [[UIPickerView alloc] initWithFrame:frame];
    [digitPicker setDataSource:self];
    [digitPicker setDelegate:self];
    [digitPicker setUserInteractionEnabled:NO];
    [digitPicker setBackgroundColor:[UIColor clearColor]];
    [digitPicker setAlpha:0.0f];
    
    // must add a top and bottom view on top of the picker to hide it's row
    // separator, which seems impossible to remove unless you know exactly the
    // index of the subview and remove at by index, which seems worse than covering it
    CGFloat coverHeight = (HEMSensorCheckPickerHeight - HEMSensorCheckValueDigitHeight)/2;
    CGRect coverFrame = CGRectZero;
    coverFrame.origin = frame.origin;
    coverFrame.size.width = width;
    coverFrame.size.height = coverHeight;
    
    UIView* topView = [[UIView alloc] init];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [topView setFrame:coverFrame];
    
    coverFrame.origin.y = CGRectGetMaxY(frame) - coverHeight;
    UIView* bottomView = [[UIView alloc] init];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [bottomView setFrame:coverFrame];
    
    UILabel* unitLabel = nil;
    if ([self sensorValueUnit] != nil) {
        unitLabel = [[UILabel alloc] init];
        [unitLabel setText:[self sensorValueUnit]];
        [unitLabel setFont:[UIFont onboardingRoomCheckSensorUnitFont]];
        [unitLabel setTextColor:[self conditionColor]];
        [unitLabel setAlpha:0.0f];
        
        CGSize constraint = {MAXFLOAT, HEMSensorCheckValueUnitHeight};
        CGSize textSize = [unitLabel sizeThatFits:constraint];
        CGRect unitFrame = {
            CGRectGetMaxX(frame),
            CGRectGetMaxY([topView frame]) + HEMSensorCheckValueUnitTopMargin,
            textSize.width,
            HEMSensorCheckValueUnitHeight
        };
        [unitLabel setFrame:unitFrame];
    }
    
    [self addSubview:digitPicker];
    [self addSubview:topView];
    [self addSubview:bottomView];
    
    if (unitLabel != nil) {
        [self addSubview:unitLabel];
        [self setUnitLabel:unitLabel];
    }
    
    [self setValueView:digitPicker];
    [self addActivityIndicatorRelativeTo:digitPicker];
    [self animateInSensorValue:[self sensorValueString] completion:completion];
}

- (void)setPicker:(UIPickerView*)picker
     digitAtIndex:(NSInteger)index
       usingValue:(NSString*)value
         animated:(BOOL)animated {
    NSInteger digit = [[NSString stringWithFormat:@"%c", [value characterAtIndex:index]] integerValue];
    [picker selectRow:digit inComponent:index animated:YES];
}

- (void)addActivityIndicatorRelativeTo:(UIView*)view {
    CGRect frame = [view frame];
    CGFloat widthDiff = CGRectGetWidth(frame) - HEMSensorCheckActivitySize;
    CGFloat heightDiff = CGRectGetHeight(frame) - HEMSensorCheckActivitySize;
    CGRect indicatorFrame = {
        CGRectGetMinX([view frame]) + (widthDiff/2),
        CGRectGetMinY([view frame]) + (heightDiff/2),
        HEMSensorCheckActivitySize,
        HEMSensorCheckActivitySize
    };
    HEMActivityIndicatorView* indicator = [[HEMActivityIndicatorView alloc] initWithFrame:indicatorFrame];
    [self addSubview:indicator];
    [self setActivityIndicator:indicator];
}

- (void)animateInSensorValue:(NSString*)value completion:(void(^)(void))completion {
    [[self activityIndicator] start];
    int64_t delaySecs = (int64_t)(HEMSensorCheckActivityDuration * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [[self activityIndicator] stop];
        [[self valueView] setAlpha:1.0f];
        [[self unitLabel] setAlpha:1.0f];
        [self animateToDigitAtIndex:[value length]-1 withinString:value completion:^{
            [self displaySensorMessage:completion];
        }];
    });

}

- (void)animateToDigitAtIndex:(NSInteger)index withinString:(NSString*)value completion:(void(^)(void))completion {
    if (index < 0) {
        if (completion) completion ();
        return;
    }
    
    [self setPicker:[self valueView] digitAtIndex:index usingValue:value animated:YES];
    
    // animate 1 digit at a time
    int64_t delaySecs = (int64_t)(HEMSensorCheckDigitDisplayDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delaySecs);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        [self animateToDigitAtIndex:index-1 withinString:value completion:completion];
    });
}

- (void)displaySensorMessage:(void(^)(void))completion {
    CGFloat splitDuration = HEMSensorCheckActivityDuration/2;
    [UIView animateWithDuration:splitDuration
                     animations:^{
                         [[self messageLabel] setAlpha:0.0f];
                     } completion:^(BOOL finished) {
                         [[self messageLabel] setAttributedText:[self sensorMessage]];
                         [UIView animateWithDuration:splitDuration
                                          animations:^{
                                              [[self messageLabel] setAlpha:1.0f];
                                          }
                                          completion:^(BOOL finished) {
                                              if (completion) completion();
                                          }];
                     }];
}

- (void)addSeparator {
    CGRect frame = {
        0.0f,
        CGRectGetHeight([self bounds]) - HEMSensorCheckSeparatorHeight,
        CGRectGetWidth([self bounds]),
        HEMSensorCheckSeparatorHeight
    };
    
    // NOTE: with half pixel on the separator, autolayout
    // causes the separator to flicker and disppear on iphone 5/5s
    // so we need to not use constraints and be forced to animate
    // it ourselves
    UIView* separator = [[UIView alloc] initWithFrame:frame];
    [separator setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.3f]];
    [separator setAlpha:0.0f];
    
    [self addSubview:separator];
    [self setSeparator:separator];
}

- (void)collapse {
    CGRect frame = [self frame];
    frame.size.height = HEMSensorCheckCollapsedHeight;
    [self setFrame:frame];
    
    // reset
    CGRect sepFrame = [[self separator] frame];
    sepFrame.origin.y = HEMSensorCheckCollapsedHeight - CGRectGetHeight(sepFrame);
    [[self separator] setFrame:sepFrame];
    
    [[self separator] setAlpha:0.0f];
    [[self titleLabel] setAlpha:0.0f];
    [[self messageLabel] setAlpha:0.0f];
}

- (void)moveTo:(CGFloat)y
   andExpandTo:(CGFloat)height
whileAnimating:(void(^)(void))animations
  onCompletion:(void(^)(BOOL finished))completion {
    
    [UIView animateWithDuration:HEMSensorCheckContentAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = [self frame];
                         frame.origin.y = y;
                         frame.size.height = height;
                         [self setFrame:frame];
                         
                         CGRect sepFrame = [[self separator] frame];
                         sepFrame.origin.y = height - CGRectGetHeight(sepFrame);
                         [[self separator] setFrame:sepFrame];
                         [[self separator] setAlpha:1.0f];
                         
                         if (animations) animations();
                     }
                     completion:^(BOOL finished) {
                         [self displayContents:completion];
                     }];
    
}

- (void)displayContents:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:HEMSensorCheckContentAnimationDuration
                     animations:^{
                         [[self iconImageView] setHighlighted:YES];
                         [[self titleLabel] setAlpha:1.0f];
                         [[self messageLabel] setAlpha:1.0f];
                     }
                     completion:completion];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [[self sensorValueString] length];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    unichar character = [[self sensorValueString] characterAtIndex:component];
    return isdigit(character) ? 10 : 1; // 0 - 9 for digit, or 1 for negative sign
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return HEMSensorCheckValueDigitWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return HEMSensorCheckValueDigitHeight;
}

- (UIView*)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
    UILabel* rowLabel = nil;
    
    if (view == nil) {
        rowLabel = [[UILabel alloc] init];
        [rowLabel setTextColor:[self conditionColor]];
        [rowLabel setFont:[UIFont onboardingRoomCheckSensorValueFont]];
        [rowLabel setBackgroundColor:[UIColor clearColor]];
    } else {
        rowLabel = (UILabel*)view;
    }
    
    NSString* labelValue = nil;
    unichar character = [[self sensorValueString] characterAtIndex:component];
    if (isdigit(character)) {
        labelValue = [NSString stringWithFormat:@"%ld", (long)row];
    } else {
        labelValue = [NSString stringWithFormat:@"%c", character];
    }
    
    [rowLabel setText:labelValue];
    [rowLabel sizeToFit];

    return rowLabel;
}

@end
