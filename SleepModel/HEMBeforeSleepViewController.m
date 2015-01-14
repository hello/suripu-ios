//
//  HEMBeforeSleepViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "UIFont+HEMStyle.h"

#import "HEMBeforeSleepViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMActivityCoverView.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMBeforeSleepViewController()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (copy, nonatomic) NSString* nextSegueId;

@end

@implementation HEMBeforeSleepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableBackButton:NO];
    [SENAnalytics track:kHEMAnalyticsEventOnBSenseColors];
}

- (IBAction)next:(id)sender {
    NSString* nextSegueId = [HEMOnboardingStoryboard beforeSleeptoRoomCheckSegueIdentifier];
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

@end
