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

@interface HEMTimelineTopBarCollectionReusableView ()

@property (weak,   nonatomic) IBOutlet UILabel *dateLabel;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *centerTitleTopConstraint;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    DDLogVerbose(@"layout subview, height %f", CGRectGetHeight([self bounds]));
}

- (void)setOpened:(BOOL)isOpen {
    UIImage *image = [UIImage imageNamed:isOpen ? @"caret up" : @"Menu"];
    [self.drawerButton setImage:image forState:UIControlStateNormal];
    CGFloat auxButtonAlpha = isOpen ? 0 : 1;
    CGFloat constant = isOpen ? HEMCenterTitleDrawerOpenTop : HEMCenterTitleDrawerClosedTop;
    self.centerTitleTopConstraint.constant = constant;
    [self setNeedsUpdateConstraints];
    
    UIColor* titleTextColor
        = isOpen
        ? [HelloStyleKit barButtonDisabledColor]
        : [UIColor colorWithWhite:0 alpha:0.7f];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [[self dateLabel] setTextColor:titleTextColor];
                         self.shareButton.alpha = auxButtonAlpha;
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
