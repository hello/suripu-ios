//
//  HEMSleepPillDfuViewController.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSleepPillDfuViewController.h"
#import "HEMActionButton.h"
#import "HEMPillDfuPresenter.h"
#import "HEMDfuService.h"

@interface HEMSleepPillDfuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;
@property (strong, nonatomic) HEMDfuService* dfuService;

@end

@implementation HEMSleepPillDfuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configurePresenter {
    HEMDfuService* dfuService = [HEMDfuService new];
    
    HEMPillDfuPresenter* dfuPresenter = [[HEMPillDfuPresenter alloc] initWithDfuService:dfuService];
    [dfuPresenter bindWithTitleLabel:[self titleLabel] descriptionLabel:[self descriptionLabel]];
    [dfuPresenter bindWithActionButton:[self continueButton]];
    
    [self setDfuService:dfuService];
    [self addPresenter:dfuPresenter];
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
