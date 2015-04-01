//
//  HEMClockPickerView.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENPreference.h>
#import <NAPickerView/NAPickerView.h>
#import "HEMClockPickerView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

typedef NS_ENUM(NSUInteger, HEMClockIndex) {
    HEMClockIndexHour = 0,
    HEMClockIndexDivider = 1,
    HEMClockIndexMinute = 2,
    HEMClockIndexMeridiem = 3,
};

@interface HEMClockPickerView ()
@property (nonatomic, strong) UIView *gradientView;
@property (nonatomic, strong) UILabel *colonLabel;
@property (nonatomic, strong) NAPickerView *hourPickerView;
@property (nonatomic, strong) NAPickerView *minutePickerView;
@property (nonatomic, strong) NAPickerView *meridiemPickerView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) NSString *selectedMeridiemText;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;

@property (nonatomic, readwrite) NSUInteger hour;
@property (nonatomic, readwrite) NSUInteger minute;
@end

@implementation HEMClockPickerView

static CGFloat const HEMClockPickerHourWidth = 90.f;
static CGFloat const HEMClockPickerMinuteWidth = 90.f;
static CGFloat const HEMClockPickerDividerWidth = 40.f;
static CGFloat const HEMClockPickerMeridiemWidth = 80.f;

static NSUInteger const HEMClockMinuteCount = 60;
static NSUInteger const HEMClock12HourCount = 12;
static NSUInteger const HEMClock24HourCount = 24;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeComponents];
        [self applyStyling];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeComponents];
        [self applyStyling];
    }
    return self;
}

- (void)initializeComponents {
    _minuteIncrement = 1;
    _use12Hour = [SENPreference timeFormat] == SENTimeFormat12Hour;
    [self initializeHourPicker];
    [self initializeDivider];
    [self initializeMinutePicker];
    if (_use12Hour) {
        [self initializeMeridiemPicker];
    }
    _gradientView = [UIView new];
    _gradientView.userInteractionEnabled = NO;
    [self addSubview:_gradientView];
    [self layoutPickerViews];
}

- (void)initializeHourPicker {
    NSInteger hourCount = _use12Hour ? 12 : 24;
    NSMutableArray *hourItems = [[NSMutableArray alloc] initWithCapacity:hourCount];
    for (int i = 0; i < hourCount; i++) {
        NSInteger hour = [self shouldUse12Hour] ? i + 1 : i;
        [hourItems addObject:[NSString stringWithFormat:@"%ld", hour]];
    }
    _hourPickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerHourWidth, CGRectGetHeight(self.bounds))
                                   andItems:hourItems
                                andDelegate:nil];
    _hourPickerView.infiniteScrolling = YES;
    _hourPickerView.backgroundColor = [UIColor clearColor];
    _hourPickerView.overlayColor = [UIColor clearColor];
    _hourPickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
      cell.textView.font = [UIFont alarmNumberFont];
      cell.textView.textColor = [HelloStyleKit backViewTextColor];
      cell.textView.textAlignment = NSTextAlignmentCenter;
      cell.textView.backgroundColor = [UIColor clearColor];
      cell.textView.text = item;
    };
    __weak typeof(self) weakSelf = self;
    _hourPickerView.highlightBlock = ^(NALabelCell *cell) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      cell.textView.textColor = [HelloStyleKit tintColor];
      cell.textView.font = [UIFont alarmSelectedNumberFont];
      [strongSelf updateHour:[cell.textView.text integerValue]];
      [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
    };
    _hourPickerView.unhighlightBlock = ^(NALabelCell *cell) {
      cell.textView.font = [UIFont alarmNumberFont];
      cell.textView.textColor = [HelloStyleKit backViewTextColor];
    };
    [_hourPickerView setIndex:0];
    [self addSubview:_hourPickerView];
}

- (void)initializeDivider {
    _colonLabel = [UILabel new];
    _colonLabel.text = NSLocalizedString(@"alarm.clock.divider", nil);
    _colonLabel.font = [UIFont alarmSelectedNumberFont];
    _colonLabel.textColor = [HelloStyleKit tintColor];
    _colonLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_colonLabel];
}

- (void)initializeMinutePicker {
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0; i < HEMClockMinuteCount; i += self.minuteIncrement) {
        NSString *format = i < 10 ? @"0%ld" : @"%ld";
        [items addObject:[NSString stringWithFormat:format, i]];
    }
    _minutePickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerMinuteWidth, CGRectGetHeight(self.bounds))
                                   andItems:items
                                andDelegate:nil];
    _minutePickerView.infiniteScrolling = YES;
    _minutePickerView.backgroundColor = [UIColor clearColor];
    _minutePickerView.overlayColor = [UIColor clearColor];
    _minutePickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
      cell.textView.font = [UIFont alarmNumberFont];
      cell.textView.textColor = [HelloStyleKit backViewTextColor];
      cell.textView.textAlignment = NSTextAlignmentCenter;
      cell.textView.backgroundColor = [UIColor clearColor];
      cell.textView.text = item;
    };
    __weak typeof(self) weakSelf = self;
    _minutePickerView.highlightBlock = ^(NALabelCell *cell) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      cell.textView.textColor = [HelloStyleKit tintColor];
      cell.textView.font = [UIFont alarmSelectedNumberFont];
      strongSelf.minute = [cell.textView.text integerValue];
      [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
    };
    _minutePickerView.unhighlightBlock = ^(NALabelCell *cell) {
      cell.textView.font = [UIFont alarmNumberFont];
      cell.textView.textColor = [HelloStyleKit backViewTextColor];
    };
    [_minutePickerView setIndex:0];
    [self insertSubview:_minutePickerView atIndex:0];
}

- (void)initializeMeridiemPicker {
    NSArray *items = @[
        [NSLocalizedString(@"alarms.alarm.meridiem.am", nil) uppercaseString],
        [NSLocalizedString(@"alarms.alarm.meridiem.pm", nil) uppercaseString]
    ];
    _meridiemPickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerMeridiemWidth, CGRectGetHeight(self.bounds))
                                   andItems:items
                                andDelegate:nil];
    _meridiemPickerView.infiniteScrolling = NO;
    _meridiemPickerView.backgroundColor = [UIColor clearColor];
    _meridiemPickerView.overlayColor = [UIColor clearColor];
    _meridiemPickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
      cell.textView.font = [UIFont alarmMeridiemFont];
      cell.textView.textColor = [HelloStyleKit backViewTextColor];
      cell.textView.textAlignment = NSTextAlignmentCenter;
      cell.textView.backgroundColor = [UIColor clearColor];
      cell.textView.text = item;
    };
    __weak typeof(self) weakSelf = self;
    _meridiemPickerView.highlightBlock = ^(NALabelCell *cell) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      cell.textView.textColor = [HelloStyleKit tintColor];
      strongSelf.selectedMeridiemText = cell.textView.text;
      [strongSelf updateHour:strongSelf.hour];
      [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
    };
    _meridiemPickerView.unhighlightBlock
        = ^(NALabelCell *cell) { cell.textView.textColor = [HelloStyleKit backViewTextColor]; };
    [_meridiemPickerView setIndex:0];
    [self addSubview:_meridiemPickerView];
}

- (void)awakeFromNib {
    [self layoutPickerViews];
}

- (void)applyStyling {
    CGRect gradientFrame = self.gradientView.bounds;
    gradientFrame.size.width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CAGradientLayer *vLayer = [CAGradientLayer layer];
    UIColor *topColor = [UIColor colorWithWhite:0.98f alpha:0.9f];
    UIColor *middleColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    vLayer.colors = @[ (id)topColor.CGColor, (id)middleColor.CGColor, (id)middleColor.CGColor, (id)topColor.CGColor ];
    vLayer.frame = gradientFrame;
    vLayer.locations = @[ @0, @(0.25), @(0.75), @1 ];
    vLayer.startPoint = CGPointZero;
    vLayer.endPoint = CGPointMake(0, 1);
    self.gradientLayer = vLayer;
    [self.gradientView.layer insertSublayer:vLayer atIndex:0];
    self.alpha = 0;
    [UIView animateWithDuration:0.25f delay:0.3f options:0 animations:^{
        self.alpha = 1;
    } completion:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutPickerViews];
}

- (void)layoutPickerViews {
    CGRect bounds = self.bounds;
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat totalItemWidth = HEMClockPickerHourWidth + HEMClockPickerMinuteWidth + HEMClockPickerDividerWidth
                             + ([self shouldUse12Hour] ? HEMClockPickerMeridiemWidth : 0);
    CGFloat offset = MAX((width - totalItemWidth) / 2, 0);
    self.gradientView.frame = bounds;
    self.gradientLayer.frame = bounds;
    self.hourPickerView.frame = CGRectMake(offset, 0, HEMClockPickerHourWidth, height);
    self.colonLabel.frame
        = CGRectMake(CGRectGetMaxX(self.hourPickerView.frame), 0, HEMClockPickerDividerWidth, height - 10);
    self.minutePickerView.frame
        = CGRectMake(CGRectGetMaxX(self.colonLabel.frame), 0, HEMClockPickerMinuteWidth, height);
    self.meridiemPickerView.frame
        = CGRectMake(CGRectGetMaxX(self.minutePickerView.frame), 0, HEMClockPickerMeridiemWidth, height);
}

- (void)updateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute {
    self.minute = minute;
    self.hour = hour;
    NSInteger minuteRow = minute / self.minuteIncrement;
    NSInteger hourRow = hour;
    NSInteger meridiemRow = hour <= (HEMClock12HourCount - 1) ? 0 : 1;
    NSInteger hourRowCount;
    if ([self shouldUse12Hour]) {
        if (hourRow > HEMClock12HourCount)
            hourRow -= HEMClock12HourCount;
        hourRow--;
        hourRowCount = HEMClock12HourCount;
    } else { hourRowCount = HEMClock24HourCount; }
    [self.hourPickerView setIndex:hourRow];
    [self.minutePickerView setIndex:minuteRow];
    if ([self shouldUse12Hour]) {
        [self.meridiemPickerView setIndex:meridiemRow];
    }
}

- (void)updateHour:(NSUInteger)hour {
    NSUInteger adjustedHour = hour;
    if ([self shouldUse12Hour]) {
        NSString *pmText = [NSLocalizedString(@"alarms.alarm.meridiem.pm", nil) uppercaseString];
        if ([self.selectedMeridiemText isEqualToString:pmText])
            adjustedHour = hour + 12;
        if (adjustedHour == 24)
            adjustedHour = 12;
        else if (adjustedHour == 12)
            adjustedHour = 0;
    }
    self.hour = adjustedHour;
}

- (void)setMinuteIncrement:(NSUInteger)minuteIncrement {
    if (_minuteIncrement != minuteIncrement) {
        _minuteIncrement = minuteIncrement;
        [_minutePickerView removeFromSuperview];
        [self initializeMinutePicker];
        [self setNeedsLayout];
    }
}

@end
