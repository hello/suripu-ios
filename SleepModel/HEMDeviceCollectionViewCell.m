//
//  HEMDeviceCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMDeviceCollectionViewCell.h"
#import "HEMActivityCoverView.h"

static CGFloat kHEMDeviceCellBaseHeight = 184.0f;
static CGFloat kHEMDeviceCellActionHeight = 269.0f;

@interface HEMDeviceCollectionViewCell()

@property (nonatomic, strong) HEMActivityCoverView* activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation HEMDeviceCollectionViewCell

+ (CGFloat)heightOfCellActionButton:(BOOL)hasActionButton {
    return hasActionButton ? kHEMDeviceCellActionHeight : kHEMDeviceCellBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    UIImage* image = [UIImage imageNamed:@"rightArrow"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[self accessoryImageView] setImage:image];
    
    [self applyStyle];
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
