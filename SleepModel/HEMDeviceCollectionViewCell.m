//
//  HEMDeviceCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMDeviceCollectionViewCell.h"
#import "HEMActivityCoverView.h"

static CGFloat kHEMDeviceCellBaseHeight = 184.0f;
static CGFloat kHEMDeviceCellActionHeight = 269.0f;

@interface HEMDeviceCollectionViewCell()

@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

@end

@implementation HEMDeviceCollectionViewCell

+ (CGFloat)heightOfCellActionButton:(BOOL)hasActionButton {
    return hasActionButton ? kHEMDeviceCellActionHeight : kHEMDeviceCellBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self nameLabel] setTextColor:[UIColor grey6]];
    [[self nameLabel] setFont:[UIFont body]];
    
    [[self lastSeenLabel] setFont:[UIFont body]];
    [[self lastSeenLabel] setTextColor:[UIColor grey5]];
    
    [[self lastSeenValueLabel] setTextColor:[UIColor grey6]];
    [[self lastSeenValueLabel] setFont:[UIFont body]];
    
    [[self property1Label] setFont:[UIFont body]];
    [[self property1Label] setTextColor:[UIColor grey5]];
    
    [[self property2Label] setFont:[UIFont body]];
    [[self property2Label] setTextColor:[UIColor grey5]];
    
    [[self property1ValueLabel] setFont:[UIFont body]];
    [[self property1ValueLabel] setTextColor:[UIColor grey6]];
    
    [[self property2ValueLabel] setFont:[UIFont body]];
    [[self property2ValueLabel] setTextColor:[UIColor grey6]];
    [[self accessoryImageView] setImage:[UIImage imageNamed:@"accessory"]];
}

- (void)prepareForReuse {
    [self showDataLoadingIndicator:YES];
    [[self property1IconView] setImage:nil];
    [[self property2InfoButton] setHidden:YES];
}

- (void)showDataLoadingIndicator:(BOOL)show {
    [[self accessoryImageView] setHidden:show];
    
    if (show) {
        [[self activityIndicator] startAnimating];
    } else {
        [[self activityIndicator] stopAnimating];
    }
}

- (void)showOverlayActivityWithText:(NSString*)text {
    if ([self activityView] == nil) {
        [self setActivityView:[[HEMActivityCoverView alloc] init]];
    }
    [[self activityView] showInView:self withText:text activity:YES completion:nil];
}

- (void)dismissOverlayActivity {
    [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
        [self setActivityView:nil];
    }];
}

@end
