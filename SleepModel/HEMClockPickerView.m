//
//  HEMClockPickerView.m
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENPreference.h>
#import <NAPickerView/NAPickerView.h>
#import "Sense-Swift.h"
#import "HEMClockPickerView.h"
#import "HEMScreenUtils.h"

typedef NS_ENUM(NSUInteger, HEMClockIndex) {
    HEMClockIndexHour = 0,
    HEMClockIndexDivider = 1,
    HEMClockIndexMinute = 2,
    HEMClockIndexMeridiem = 3,
};

@interface HEMClockPickerView ()    
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* separatorHeightConstraint;
@property (nonatomic, weak) IBOutlet UIView* topGradientView;
@property (nonatomic, weak) IBOutlet UIView* botGradientView;
@property (nonatomic, strong) UILabel *colonLabel;
@property (nonatomic, strong) NAPickerView *hourPickerView;
@property (nonatomic, strong) NAPickerView *minutePickerView;
@property (nonatomic, strong) NAPickerView *meridiemPickerView;
@property (nonatomic, strong) NSString *selectedMeridiemText;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;
@property (nonatomic, strong) UIView* selectionUnderlay;

@property (nonatomic, readwrite) NSUInteger hour;
@property (nonatomic, readwrite) NSUInteger minute;

@property (nonatomic, strong) UIFont* selectedFont;
@property (nonatomic, strong) UIColor* selectedColor;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* color;

@end

@implementation HEMClockPickerView

static CGFloat const HEMClockPickerDarkGradient = 0.8f;
static CGFloat const HEMClockPickerLightGradient = 0.05f;

static CGFloat const HEMClockPickerSeparatorHeight = 0.5f;
static CGFloat const HEMClockPickerHourWidth = 90.f;
static CGFloat const HEMClockPickerMinuteWidth = 90.f;
static CGFloat const HEMClockPickerDividerWidth = 40.f;
static CGFloat const HEMClockPickerMeridiemWidth = 80.f;

static NSUInteger const HEMClockMinuteCount = 60;
static NSUInteger const HEMClock12HourCount = 12;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureStyles];
        [self initializeComponents];
        [self display];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureStyles];
        [self initializeComponents];
        [self display];
    }
    return self;
}

- (void)configureStyles {
    [self setSelectedColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyTextHighlightedColor]];
    [self setSelectedFont:[SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont]];
    [self setColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor]];
    [self setFont:[SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont]];
}

- (void)initializeComponents {
    [self setBackgroundColor:[SenseStyle colorWithAClass:[self class]
                                                property:ThemePropertyBackgroundColor]];
    
    _minuteIncrement = 1;
    _use12Hour = [SENPreference timeFormat] == SENTimeFormat12Hour;
    [self initializeHourPicker];
    [self initializeDivider];
    [self initializeMinutePicker];
    if (_use12Hour) {
        [self initializeMeridiemPicker];
    }
    [self layoutPickerViews];
}

- (void)initializeHourPicker {
    NSInteger hourCount = _use12Hour ? 12 : 24;
    NSMutableArray *hourItems = [[NSMutableArray alloc] initWithCapacity:hourCount];
    for (int i = 0; i < hourCount; i++) {
        NSString* format = _use12Hour ? @"%ld" : @"%02ld";
        NSInteger hour = [self shouldUse12Hour] ? i + 1 : i;
        [hourItems addObject:[NSString stringWithFormat:format, hour]];
    }
    
    __weak typeof(self) weakSelf = self;
    
    _hourPickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerHourWidth, CGRectGetHeight(self.bounds))
                                   andItems:hourItems
                                andDelegate:nil];
    _hourPickerView.infiniteScrolling = YES;
    _hourPickerView.backgroundColor = [UIColor clearColor];
    _hourPickerView.overlayColor = [UIColor clearColor];
    _hourPickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        cell.textView.font = [strongSelf font];
        cell.textView.textColor = [strongSelf color];
        cell.textView.textAlignment = NSTextAlignmentCenter;
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.text = item;
    };
    
    _hourPickerView.highlightBlock = ^(NALabelCell *cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf updateHour:[cell.textView.text integerValue]];
        [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
        cell.textView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        cell.textView.font = [strongSelf selectedFont];
        [UIView animateWithDuration:0.2f
                         animations:^{
                             cell.textView.textColor = [strongSelf selectedColor];
                             cell.textView.transform = CGAffineTransformIdentity;
                         }];
    };
    _hourPickerView.unhighlightBlock = ^(NALabelCell *cell) {
       if (cell.textView.font.pointSize != [UIFont alarmNumberFont].pointSize) {
           __strong typeof(weakSelf) strongSelf = weakSelf;
           cell.textView.font = [strongSelf font];
           cell.textView.transform = CGAffineTransformMakeScale(2, 2);
           [UIView animateWithDuration:0.2f
                            animations:^{
                                cell.textView.transform = CGAffineTransformIdentity;
                                cell.textView.textColor = [strongSelf color];
                            }];
       }
    };
    [_hourPickerView setIndex:0];
    [self insertSubview:_hourPickerView atIndex:0];
}

- (void)initializeDivider {
    _colonLabel = [UILabel new];
    _colonLabel.text = NSLocalizedString(@"alarm.clock.divider", nil);
    _colonLabel.font = [self font];
    _colonLabel.textColor = [self color];
    _colonLabel.textAlignment = NSTextAlignmentCenter;
    [self insertSubview:_colonLabel atIndex:0];
}

- (void)initializeMinutePicker {
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0; i < HEMClockMinuteCount; i += self.minuteIncrement) {
        NSString *format = i < 10 ? @"0%ld" : @"%ld";
        [items addObject:[NSString stringWithFormat:format, i]];
    }
    
    __weak typeof(self) weakSelf = self;
    
    _minutePickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerMinuteWidth, CGRectGetHeight(self.bounds))
                                   andItems:items
                                andDelegate:nil];
    _minutePickerView.infiniteScrolling = YES;
    _minutePickerView.backgroundColor = [UIColor clearColor];
    _minutePickerView.overlayColor = [UIColor clearColor];
    _minutePickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        cell.textView.font = [strongSelf font];
        cell.textView.textColor = [strongSelf color];
        cell.textView.textAlignment = NSTextAlignmentCenter;
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.text = item;
    };

    _minutePickerView.highlightBlock = ^(NALabelCell *cell) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      strongSelf.minute = [cell.textView.text integerValue];
      [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
      cell.textView.transform = CGAffineTransformMakeScale(0.5, 0.5);
      cell.textView.font = [strongSelf selectedFont];
      [UIView animateWithDuration:0.2f
                       animations:^{
                         cell.textView.textColor = [strongSelf selectedColor];
                         cell.textView.transform = CGAffineTransformIdentity;
                       }];
    };
    _minutePickerView.unhighlightBlock = ^(NALabelCell *cell) {
      if (cell.textView.font.pointSize != [UIFont alarmNumberFont].pointSize) {
          __strong typeof(weakSelf) strongSelf = weakSelf;
          cell.textView.font = [strongSelf font];
          cell.textView.transform = CGAffineTransformMakeScale(2, 2);
          [UIView animateWithDuration:0.2f
                           animations:^{
                             cell.textView.transform = CGAffineTransformIdentity;
                             cell.textView.textColor = [strongSelf color];
                           }];
      }
    };
    [_minutePickerView setIndex:0];
    [self insertSubview:_minutePickerView atIndex:0];
}

- (void)initializeMeridiemPicker {
    NSArray *items = @[
        [NSLocalizedString(@"alarms.alarm.meridiem.am", nil) uppercaseString],
        [NSLocalizedString(@"alarms.alarm.meridiem.pm", nil) uppercaseString]
    ];
    
    __weak typeof(self) weakSelf = self;
    
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyHintFont];
    
    _meridiemPickerView =
        [[NAPickerView alloc] initWithFrame:CGRectMake(0, 0, HEMClockPickerMeridiemWidth, CGRectGetHeight(self.bounds))
                                   andItems:items
                                andDelegate:nil];
    _meridiemPickerView.infiniteScrolling = NO;
    _meridiemPickerView.backgroundColor = [UIColor clearColor];
    _meridiemPickerView.overlayColor = [UIColor clearColor];
    _meridiemPickerView.configureBlock = ^(NALabelCell *cell, NSString *item) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        cell.textView.font = font;
        cell.textView.textColor = [strongSelf color];
        cell.textView.textAlignment = NSTextAlignmentCenter;
        cell.textView.backgroundColor = [UIColor clearColor];
        cell.textView.text = item;
    };
    _meridiemPickerView.highlightBlock = ^(NALabelCell *cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        cell.textView.textColor = [strongSelf selectedColor];
        strongSelf.selectedMeridiemText = cell.textView.text;
        [strongSelf updateHour:strongSelf.hour];
        [strongSelf.delegate didUpdateTimeToHour:strongSelf.hour minute:strongSelf.minute];
    };
    _meridiemPickerView.unhighlightBlock = ^(NALabelCell *cell) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        cell.textView.textColor = [strongSelf color];
    };
    [_meridiemPickerView setIndex:0];
    [self insertSubview:_meridiemPickerView atIndex:0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutPickerViews];
}

- (void)addGradient:(NSArray*)colors toView:(UIView*)view {
    if (view && colors) {
        [[[view layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        
        CAGradientLayer* layer = [CAGradientLayer layer];
        [layer setFrame:[view bounds]];
        [layer setColors:colors];
        [[view layer] addSublayer:layer];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setUserInteractionEnabled:NO];
    }
}

- (void)configureGradientViews {
    UIColor* darkGradient = [[self backgroundColor] colorWithAlphaComponent:HEMClockPickerDarkGradient];
    UIColor* lightGradient = [[self backgroundColor] colorWithAlphaComponent:HEMClockPickerLightGradient];
    NSArray* colors = @[(id)[darkGradient CGColor], (id)[lightGradient CGColor]];
    
    [[self separator] setBackgroundColor:[SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor]];
    [self addGradient:colors
               toView:[self topGradientView]];
    
    [self addGradient:[[colors reverseObjectEnumerator] allObjects]
               toView:[self botGradientView]];
}

- (void)display {
    [self setClipsToBounds:NO];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.25f
                          delay:0.3f
                        options:0
                     animations:^{
                       self.alpha = 1;
                     }
                     completion:NULL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutPickerViews];
    [self layoutUnderlay];
    [self configureGradientViews];
}

- (void)layoutUnderlay {
    if ([self selectionUnderlay]) {
        CGFloat centerY = CGRectGetHeight([self bounds]) / 2.0f;
        CGPoint underlayCenter = [[self selectionUnderlay] center];
        underlayCenter.y = centerY;
        [[self selectionUnderlay] setCenter:underlayCenter];
    }
}

- (void)layoutPickerViews {
    [[self separatorHeightConstraint] setConstant:HEMClockPickerSeparatorHeight];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat totalItemWidth = HEMClockPickerHourWidth + HEMClockPickerMinuteWidth + HEMClockPickerDividerWidth
                             + ([self shouldUse12Hour] ? HEMClockPickerMeridiemWidth : 0);
    CGFloat offset = MAX((width - totalItemWidth) / 2, 0);
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
    if ([self shouldUse12Hour]) {
        if (hourRow > HEMClock12HourCount)
            hourRow -= HEMClock12HourCount;
        hourRow--;
    }
    [self.hourPickerView setIndex:hourRow];
    [self.minutePickerView setIndex:minuteRow];
    if ([self shouldUse12Hour]) {
        [self.meridiemPickerView setIndex:meridiemRow];
    }
}

- (BOOL)isPMSelected {
    NSString *pmText = [NSLocalizedString(@"alarms.alarm.meridiem.pm", nil) uppercaseString];
    return [self.selectedMeridiemText isEqualToString:pmText];
}

- (void)adjustMeridiemWithHour:(NSUInteger)hour {
    if (hour == self.hour)
        return;
    BOOL counterclockwise = (self.hour == 12 || self.hour == 0) && (hour == 11 || hour == 23);
    BOOL clockwise = (hour == 0 || hour == 12) && (self.hour == 23 || self.hour == 11);
    if (clockwise || counterclockwise) {
        int index = [self isPMSelected] ? 0 : 1;
        [self.meridiemPickerView.layer removeAllAnimations];
        [self.meridiemPickerView setIndex:index animated:YES];
        NSString* key = [NSString stringWithFormat:@"alarms.alarm.meridiem.%@", index == 0 ? @"am" : @"pm"];
        self.selectedMeridiemText = [NSLocalizedString(key, nil) uppercaseString];
    }
}

- (void)updateHour:(NSUInteger)hour {
    NSUInteger adjustedHour = hour;
    if ([self shouldUse12Hour]) {
        [self adjustMeridiemWithHour:hour];
        if ([self isPMSelected]) {
            if (adjustedHour < HEMClock12HourCount)
                adjustedHour = hour + 12;
        } else {
            if (adjustedHour >= HEMClock12HourCount)
                adjustedHour = hour - 12;
        }
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
