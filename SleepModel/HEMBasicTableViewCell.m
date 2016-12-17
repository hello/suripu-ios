//
//  HEMBasicTableViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBasicTableViewCell.h"
#import "HEMActivityIndicatorView.h"
#import "HEMStyle.h"

static CGFloat const HEMBasicTableViewCellSeparatorHeight = 0.5f;
static CGFloat const kHEMBasicCellFadeDuration = 0.5f;

@interface HEMBasicTableViewCell()

@property (strong, nonatomic) UIView* customSeparator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingCustomAccessoryConstraint;
@property (assign, nonatomic) CGFloat origLeadingAccessoryMargin;

@end

@implementation HEMBasicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self activityView] setUserInteractionEnabled:NO];
    [[self activityView] setIndicatorImage:[UIImage imageNamed:@"smallLoaderGray"]];
    [self setOrigLeadingAccessoryMargin:[[self leadingCustomAccessoryConstraint] constant]];
}

- (void)showSeparator:(BOOL)show {
    if (![self customSeparator] && show) {
        CGFloat cellHeight = CGRectGetHeight([self bounds]);
        CGFloat y = cellHeight - HEMBasicTableViewCellSeparatorHeight;
        CGRect separatorFrame = CGRectZero;
        separatorFrame.size.height = HEMBasicTableViewCellSeparatorHeight;
        separatorFrame.origin.y = y;
        UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
        [separator setBackgroundColor:[UIColor separatorColor]];
        [self setCustomSeparator:separator];
        [[self contentView] addSubview:separator];
    }
    [[self customSeparator] setHidden:!show];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![[self customSeparator] isHidden]) {
        CGFloat cellHeight = CGRectGetHeight([self bounds]);
        CGFloat cellWidth = CGRectGetWidth([self bounds]);
        CGFloat labelMinX = CGRectGetMinX([[self textLabel] frame]);
        CGFloat y = cellHeight - HEMBasicTableViewCellSeparatorHeight;
        CGRect separatorFrame = [[self customSeparator] frame];
        separatorFrame.size.height = HEMBasicTableViewCellSeparatorHeight;
        separatorFrame.size.width = cellWidth - labelMinX;
        separatorFrame.origin.y = y;
        separatorFrame.origin.x = labelMinX;
        [[self customSeparator] setFrame:separatorFrame];
    }

}

- (void)showActivity:(BOOL)show {
    [[self detailTextLabel] setHidden:show];
    [[self customDetailLabel] setHidden:show];
    [[self customAccessoryView] setHidden:show];
    [[self accessoryView] setHidden:show];
    
    [self setLoading:show];
    
    if (show) {
        [[self activityView] start];
        [[self activityView] setHidden:NO];
        [[self detailTextLabel] setAlpha:0.0f];
        [[self customDetailLabel] setAlpha:0.0f];
        [[self customAccessoryView] setAlpha:0.0f];
        [[self accessoryView] setAlpha:0.0f];
        
    } else {
        [[self activityView] stop];
        [[self activityView] setHidden:YES];
        
        [UIView animateWithDuration:kHEMBasicCellFadeDuration animations:^{
            [[self detailTextLabel] setAlpha:1.0f];
            [[self customDetailLabel] setAlpha:1.0f];
            [[self customAccessoryView] setAlpha:1.0f];
            [[self accessoryView] setAlpha:1.0f];
        }];
    }
}

- (void)showCustomAccessoryView:(BOOL)show {
    [[self customAccessoryView] setHidden:!show];
    if (!show) {
        CGFloat width = CGRectGetWidth([[self customAccessoryView] bounds]);
        [[self leadingCustomAccessoryConstraint] setConstant:width];
    } else {
        [[self leadingCustomAccessoryConstraint] setConstant:[self origLeadingAccessoryMargin]];
    }
}

@end
