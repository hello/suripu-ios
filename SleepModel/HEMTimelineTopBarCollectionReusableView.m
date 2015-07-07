//
//  HEMTimelineHeaderCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSDate+HEMRelative.h"

#import "HEMTimelineTopBarCollectionReusableView.h"
#import "HelloStyleKit.h"

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
}

- (void)setDate:(NSDate*)date {
    NSDate* previousDay = [[NSDate date] previousDay];
    NSDateComponents *diff = [self.calendar components:NSDayCalendarUnit
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
}

- (NSString*)dateTitle {
    return [[self dateLabel] text];
}

- (void)setOpened:(BOOL)isOpen {
    UIImage *image = [UIImage imageNamed:isOpen ? @"caret up" : @"Menu"];
    [self.drawerButton setImage:image forState:UIControlStateNormal];
    
    CGFloat shareButtonAlpha = 1.0f;
    CGFloat titleConstant = HEMCenterTitleDrawerClosedTop;
    CGFloat drawerConstant = HEMDrawerButtonClosedTop;
    
    if (isOpen) {
        shareButtonAlpha = 0.0f;
        titleConstant = HEMCenterTitleDrawerOpenTop;
        drawerConstant = HEMDrawerButtonOpenTop;
    }

    [[self centerTitleTopConstraint] setConstant:titleConstant];
    [[self drawerTopConstraint] setConstant:drawerConstant];
    [self setNeedsUpdateConstraints];
    
    UIColor* titleTextColor
        = isOpen
        ? [HelloStyleKit barButtonDisabledColor]
        : [UIColor colorWithWhite:0 alpha:0.7f];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [[self dateLabel] setTextColor:titleTextColor];
                         self.shareButton.alpha = shareButtonAlpha;
                         [self layoutIfNeeded];
                     }];
}

- (void)setShareEnabled:(BOOL)enabled animated:(BOOL)animated {
    void(^animations)(void) = ^{
        [[self shareButton] setAlpha:enabled];
    };
    
    void(^completion)(BOOL finished) = ^(BOOL finished){
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
