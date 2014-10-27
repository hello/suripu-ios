//
//  HEMPillIntroViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPillIntroViewController.h"
#import "HEMActionButton.h"

@interface HEMPillIntroViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *videoContainer;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMPillIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SENAnalytics track:kHEMAnalyticsEventOnBSetupPill];
}

#pragma mark - Actions

- (IBAction)help:(id)sender {
    DDLogVerbose(@"WARNING: this has not been implemented yet!");
    // TODO (jimmy): the help website is still being discussed / worked on.  When
    // we know what to actually point to, we likely will open up a browser to
    // show the help
    [SENAnalytics track:kHEMAnalyticsEventHelp];
}

@end
