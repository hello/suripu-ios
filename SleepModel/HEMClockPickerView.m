//
//  HEMClockPickerView.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENPreference.h>
#import "HEMClockPickerView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

typedef NS_ENUM(NSUInteger, HEMClockIndex) {
    HEMClockIndexHour = 0,
    HEMClockIndexDivider = 1,
    HEMClockIndexMinute = 2,
    HEMClockIndexMeridiem = 3,
};

@interface HEMClockPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UIView* gradientView;
@property (nonatomic, strong) UIView* overlayView;
@property (nonatomic, strong) UILabel* selectedHourLabel;
@property (nonatomic, strong) UILabel* selectedMinuteLabel;
@property (nonatomic, strong) UILabel* selectedMeridiemLabel;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;

@property (nonatomic, readwrite) NSUInteger hour;
@property (nonatomic, readwrite) NSUInteger minute;
@end

@implementation HEMClockPickerView

static CGFloat const HEMClockPickerHeightOffset = 60.f;
static CGFloat const HEMClockPickerTopOffset = 30.f;
static CGFloat const HEMClockPickerRowHeight = 70.f;
static CGFloat const HEMClockPickerDividerWidth = 12.f;
static CGFloat const HEMClockPickerMeridiemWidth = 60.f;
static CGFloat const HEMClockPickerDefaultWidth = 90.f;
static CGFloat const HEMClockPickerExpandedWidth = 120.f;
static NSUInteger const HEMClockMinuteCount = 60;
static NSUInteger const HEMClock12HourCount = 12;
static NSUInteger const HEMClock24HourCount = 24;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initializeComponents];
        [self applyStyling];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeComponents];
        [self applyStyling];
    }
    return self;
}

- (void)initializeComponents
{
    _minuteIncrement = 1;
    _use12Hour = [SENPreference timeFormat] == SENTimeFormat12Hour;
    _pickerView = [UIPickerView new];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _gradientView = [UIView new];
    _overlayView = [UIView new];
    _overlayView.userInteractionEnabled = NO;
    [self addSubview:self.gradientView];
    [self addSubview:self.pickerView];
    [self addSubview:self.overlayView];
    [self layoutPickerViews];
}

- (void)awakeFromNib
{
    [self layoutPickerViews];
}

- (void)applyStyling
{
    CGRect gradientFrame = self.gradientView.bounds;
    gradientFrame.size.width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CAGradientLayer* vLayer = [CAGradientLayer layer];
    vLayer.colors = @[
        (id)[UIColor colorWithWhite:0.98f alpha:0.7f].CGColor,
        (id)[UIColor whiteColor].CGColor,
        (id)[UIColor whiteColor].CGColor,
        (id)[UIColor colorWithWhite:0.98f alpha:0.7f].CGColor];
    vLayer.frame = gradientFrame;
    vLayer.locations = @[ @0, @(0.15), @(0.85), @1 ];
    vLayer.startPoint = CGPointZero;
    vLayer.endPoint = CGPointMake(0, 1);
    [self.gradientView.layer insertSublayer:vLayer atIndex:0];
    CAGradientLayer* hLayer = [CAGradientLayer layer];
    hLayer.colors = @[
        (id)[UIColor colorWithWhite:0.98f alpha:1.f].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0].CGColor,
        (id)[UIColor colorWithWhite:1.f alpha:0].CGColor,
        (id)[UIColor colorWithWhite:0.98f alpha:1.f].CGColor];
    hLayer.frame = gradientFrame;
    hLayer.locations = @[ @0, @(0.25), @(0.75), @1 ];
    hLayer.startPoint = CGPointMake(0, 0.5);
    hLayer.endPoint = CGPointMake(1, 0.5);
    [self.overlayView.layer insertSublayer:hLayer atIndex:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutPickerViews];
}

- (void)layoutPickerViews
{
    CGRect bounds = self.bounds;
    self.gradientView.frame = bounds;
    self.overlayView.frame = bounds;
    CGRect pickerFrame = bounds;
    pickerFrame.size.height -= HEMClockPickerHeightOffset;
    pickerFrame.origin.y = HEMClockPickerTopOffset;
    self.pickerView.frame = pickerFrame;
}

- (void)configurePickerView
{
    NSInteger hourRowCount = [self realNumberOfRowsInComponent:HEMClockIndexHour];
    [self.pickerView selectRow:(INT16_MAX/(2*hourRowCount))*hourRowCount
                   inComponent:HEMClockIndexHour animated:NO];
    NSInteger minuteRowCount = [self realNumberOfRowsInComponent:HEMClockIndexMinute];
    [self.pickerView selectRow:(INT16_MAX/(2*minuteRowCount))*minuteRowCount
                   inComponent:HEMClockIndexMinute animated:NO];
}

- (void)updateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute
{
    self.minute = minute;
    self.hour = hour;
    NSInteger minuteRow = minute / self.minuteIncrement;
    NSInteger hourRow = hour;
    NSInteger meridiemRow = hour <= (HEMClock12HourCount - 1) ? 0 : 1;
    if ([self shouldUse12Hour]) {
        if (hourRow > HEMClock12HourCount)
            hourRow -= HEMClock12HourCount;
        hourRow--;
    }
    NSInteger hourRowCount = [self realNumberOfRowsInComponent:HEMClockIndexHour];
    NSInteger hourOffset = (INT16_MAX/(2*hourRowCount))*hourRowCount;
    hourRow += hourOffset;
    NSInteger minuteRowCount = [self realNumberOfRowsInComponent:HEMClockIndexMinute];
    NSInteger minuteOffset = (INT16_MAX/(2*minuteRowCount))*minuteRowCount;
    minuteRow += minuteOffset;
    [self.pickerView selectRow:hourRow
                   inComponent:HEMClockIndexHour animated:NO];
    [self.pickerView selectRow:minuteRow
                   inComponent:HEMClockIndexMinute animated:NO];

    self.selectedHourLabel = (id)[self.pickerView viewForRow:hourRow
                                                forComponent:HEMClockIndexHour];
    self.selectedMinuteLabel = (id)[self.pickerView viewForRow:minuteRow
                                                  forComponent:HEMClockIndexMinute];
    [self configureLabel:self.selectedHourLabel
                selected:YES component:HEMClockIndexHour];
    [self configureLabel:self.selectedMinuteLabel
                selected:YES component:HEMClockIndexMinute];
    if ([self shouldUse12Hour]) {
        [self.pickerView selectRow:meridiemRow
                       inComponent:HEMClockIndexMeridiem animated:NO];
        self.selectedMeridiemLabel = (id)[self.pickerView viewForRow:meridiemRow
                                                        forComponent:HEMClockIndexMeridiem];
        [self configureLabel:self.selectedMeridiemLabel
                    selected:YES component:HEMClockIndexMeridiem];
    }
}

#pragma mark - UIPickerView

- (void)configureLabel:(UILabel *)label selected:(BOOL)isSelected component:(NSUInteger)component
{
    if (component == HEMClockIndexMeridiem) {
        label.font = [UIFont alarmMeridiemFont];
    } else {
        label.font = [UIFont alarmNumberFont];
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.4f, 1.4f);
        CGAffineTransform selectedTransform;
        if (component == HEMClockIndexHour)
            selectedTransform = CGAffineTransformTranslate(scaleTransform, -CGRectGetWidth(label.bounds)/7, 0);
        else
            selectedTransform = scaleTransform;
        CGAffineTransform transform = isSelected ? selectedTransform : CGAffineTransformIdentity;
        if (!CGAffineTransformEqualToTransform(transform, label.transform))
            label.transform = transform;
    }
    label.textColor = isSelected ? [HelloStyleKit tintColor] : [UIColor grayColor];
}

- (void)updateHourWithSelectedRow:(NSUInteger)row
{
    NSUInteger adjustedRow = row;
    if ([self shouldUse12Hour]) {
        NSString* pmText = [self textForRow:1 forComponent:HEMClockIndexMeridiem];
        if ([self.selectedMeridiemLabel.text isEqualToString:pmText]) {
            adjustedRow = row + 13;
        } else {
            adjustedRow = row + 1;
        }
        if (adjustedRow == 24)
            adjustedRow = 12;
        else if (adjustedRow == 12)
            adjustedRow = 0;
    }
    self.hour = adjustedRow;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self shouldUse12Hour] ? 4 : 3;
}

- (NSInteger)realNumberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case HEMClockIndexHour: return [self shouldUse12Hour] ? HEMClock12HourCount : HEMClock24HourCount;
        case HEMClockIndexDivider: return 1;
        case HEMClockIndexMinute: return HEMClockMinuteCount / self.minuteIncrement;
        case HEMClockIndexMeridiem: return 2;
        default: return 0;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case HEMClockIndexHour:
        case HEMClockIndexMinute:
            return INT16_MAX;
        default:
            return [self realNumberOfRowsInComponent:component];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString* text = [self textForRow:row forComponent:component];
    UILabel* label = (id)view ?: [UILabel new];
    label.text = text;
    label.textAlignment = [self textAlignmentForComponent:component];
    BOOL isSelectedRow = (component == HEMClockIndexHour && [label.text isEqualToString:self.selectedHourLabel.text])
        || (component == HEMClockIndexMinute && [label.text isEqualToString:self.selectedMinuteLabel.text])
        || (component == HEMClockIndexDivider)
        || (component == HEMClockIndexMeridiem && [label.text isEqualToString:self.selectedMeridiemLabel.text]);
    [self configureLabel:label selected:isSelectedRow component:component];
    return label;
}

- (NSString *)textForRow:(NSInteger)loopedRow forComponent:(NSInteger)component
{
    NSInteger realCount = [self realNumberOfRowsInComponent:component];
    NSInteger row = realCount > 0 ? loopedRow % realCount : 0;
    switch (component) {
        case HEMClockIndexHour: {
            NSInteger hour = [self shouldUse12Hour] ? row + 1 : row;
            return [NSString stringWithFormat:@"%ld", hour];
        }
        case HEMClockIndexMinute: {
            NSInteger minute = row * self.minuteIncrement;
            NSString* format = minute < 10 ? @"0%ld" : @"%ld";
            return [NSString stringWithFormat:format, minute];
        }
        case HEMClockIndexMeridiem: {
            NSString* format = row == 0 ? @"alarms.alarm.meridiem.am" : @"alarms.alarm.meridiem.pm";
            return [NSLocalizedString(format, nil) uppercaseString];
        }
        case HEMClockIndexDivider: return NSLocalizedString(@"alarm.clock.divider", nil);
        default: return nil;
    }
}

- (NSTextAlignment)textAlignmentForComponent:(NSInteger)component
{
    switch (component) {
        case HEMClockIndexHour:
            return NSTextAlignmentRight;
        case HEMClockIndexDivider:
        case HEMClockIndexMeridiem:
            return NSTextAlignmentLeft;
        case HEMClockIndexMinute: {
            if (![self shouldUse12Hour])
                return NSTextAlignmentLeft;
        }
        default: return NSTextAlignmentCenter;
    }
}

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)loopedRow inComponent:(NSInteger)component
{
    NSInteger rowCount = [self realNumberOfRowsInComponent:component];
    NSInteger row = rowCount > 0 ? loopedRow % rowCount : 0;
    UILabel* oldSelectedLabel;
    UILabel* selectedLabel = (id)[pickerView viewForRow:loopedRow forComponent:component];
    switch (component) {
        case HEMClockIndexHour: {
            oldSelectedLabel = self.selectedHourLabel;
            self.selectedHourLabel = selectedLabel;
            [self updateHourWithSelectedRow:row];
        } break;
        case HEMClockIndexMinute: {
            oldSelectedLabel = self.selectedMinuteLabel;
            self.selectedMinuteLabel = selectedLabel;
            self.minute = row * self.minuteIncrement;
        } break;
        case HEMClockIndexMeridiem: {
            oldSelectedLabel = self.selectedMeridiemLabel;
            self.selectedMeridiemLabel = selectedLabel;
            NSUInteger selectedHourRow = [pickerView selectedRowInComponent:HEMClockIndexHour]
                % [self realNumberOfRowsInComponent:HEMClockIndexHour];
            [self updateHourWithSelectedRow:selectedHourRow];
        } break;
        default:
            break;
    }
    if (![selectedLabel.text isEqual:oldSelectedLabel.text]) {
        [UIView animateWithDuration:0.25f animations:^{
            [self configureLabel:selectedLabel selected:YES component:component];
            if (oldSelectedLabel)
                [self configureLabel:oldSelectedLabel selected:NO component:component];
        } completion:^(BOOL finished) {
            [self.pickerView setNeedsLayout];
        }];
    }
    [self.delegate didUpdateTimeToHour:self.hour minute:self.minute];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case HEMClockIndexDivider: return HEMClockPickerDividerWidth;
        case HEMClockIndexMeridiem: return HEMClockPickerMeridiemWidth;
        case HEMClockIndexMinute: {
            if (![self shouldUse12Hour])
                return HEMClockPickerExpandedWidth;
        }
        default: return HEMClockPickerDefaultWidth;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return HEMClockPickerRowHeight;
}

@end
