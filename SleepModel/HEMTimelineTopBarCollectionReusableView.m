//
//  HEMTimelineHeaderCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSDate+HEMRelative.h"

#import "HEMTimelineTopBarCollectionReusableView.h"
#import "UIColor+HEMStyle.h"

static CGFloat const HEMCenterTitleDrawerClosedTop = 20.f;
static CGFloat const HEMCenterTitleDrawerOpenTop = 10.f;
static CGFloat const HEMDrawerButtonOpenTop = 4.0f;
static CGFloat const HEMDrawerButtonClosedTop = 12.0f;

@interface HEMTimelineTopBarCollectionReusableView ()

@property (weak,   nonatomic) IBOutlet UILabel *dateLabel;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *centerTitleTopConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *drawerTopConstraint;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDateFormatter *weekdayDateFormatter;
@property (strong, nonatomic) NSDateFormatter *rangeDateFormatter;

@end

@implementation HEMTimelineTopBarCollectionReusableView

- (void)awakeFromNib {
    self.rangeDateFormatter = [NSDateFormatter new];
    self.rangeDateFormatter.dateFormat = @"MMMM d";
    self.weekdayDateFormatter = [NSDateFormatter new];
    self.weekdayDateFormatter.dateFormat = @"EEEE";
    self.calendar = [NSCalendar autoupdatingCurrentCalendar];
    self.drawerButton.accessibilityHint = NSLocalizedString(@"timeline.accessibility-hint.menu-open", nil);
    self.drawerButton.accessibilityLabel = NSLocalizedString(@"timeline.accessibility-label.menu", nil);
    self.dateLabel.isAccessibilityElement = NO;
    self.dateButton.accessibilityHint = NSLocalizedString(@"timeline.accessibility-hint.history-open", nil);
}

- (void)setDate:(NSDate*)date {
    NSDate* previousDay = [[NSDate date] previousDay];
    NSDateComponents *diff = [self.calendar components:NSCalendarUnitDay
                                              fromDate:date
                                                toDate:previousDay
                                               options:0];
    
    NSString* title = nil;
    
    if (diff.day == 0)
        title =  NSLocalizedString(@"sleep-history.last-night", nil);
    else if (diff.day < 7)
        title =  [self.weekdayDateFormatter stringFromDate:date];
    else
        title = [self.rangeDateFormatter stringFromDate:date];
    
    [[self dateLabel] setText:title];
    self.dateButton.accessibilityValue = title;
}

- (NSString*)dateTitle {
    return [[self dateLabel] text];
}

- (void)setOpened:(BOOL)isOpen {
    UIImage *image = [UIImage imageNamed:isOpen ? @"caret up" : @"Menu"];
    [self.drawerButton setImage:image forState:UIControlStateNormal];

    CGFloat titleConstant = HEMCenterTitleDrawerClosedTop;
    CGFloat drawerConstant = HEMDrawerButtonClosedTop;
    UIColor* titleTextColor;
    NSString* accessibilityHint;
    if (isOpen) {
        titleConstant = HEMCenterTitleDrawerOpenTop;
        drawerConstant = HEMDrawerButtonOpenTop;
        titleTextColor = [UIColor barButtonDisabledColor];
        accessibilityHint = NSLocalizedString(@"timeline.accessibility-hint.menu-close", nil);
        self.dateButton.isAccessibilityElement = NO;
    } else {
        titleTextColor = [UIColor colorWithWhite:0 alpha:0.7f];
        accessibilityHint = NSLocalizedString(@"timeline.accessibility-hint.menu-open", nil);
        self.dateButton.isAccessibilityElement = YES;
    }
    self.drawerButton.accessibilityHint = accessibilityHint;
    [[self centerTitleTopConstraint] setConstant:titleConstant];
    [[self drawerTopConstraint] setConstant:drawerConstant];
    [self setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [[self dateLabel] setTextColor:titleTextColor];
                         [self layoutIfNeeded];
                     }];
}

- (void)setShareEnabled:(BOOL)enabled animated:(BOOL)animated {
    void(^animations)(void) = ^{
        [[self shareButton] setAlpha:enabled];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
        [[self shareButton] setEnabled:enabled];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f
                         animations:animations
                         completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

@end
