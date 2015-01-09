//
//  HEMDeviceCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMDeviceCollectionViewCell.h"
#import "HEMActivityCoverView.h"

@interface HEMDeviceCollectionViewCell()

@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImageView;

@end

@implementation HEMDeviceCollectionViewCell

- (void)prepareForReuse {
    [self showDataLoadingIndicator:YES];
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
