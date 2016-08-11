//
//  HEMHaveSenseViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/3/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"

#import "HEMHaveSenseViewController.h"
#import "HEMOnboardingNewSensePresenter.h"
#import "HEMSensePairViewController.h"
#import "HEMSupportUtil.h"
#import "HEMOnboardingStoryboard.h"

@interface HEMHaveSenseViewController() <HEMNewSenseActionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *orderSenseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation HEMHaveSenseViewController

- (void)viewDidLoad {
    [self configurePresenter]; // must be called before viewDidLoad
    [super viewDidLoad];
}

- (void)configurePresenter {
    if (![self presenter]) {
        [self setPresenter:[HEMOnboardingNewSensePresenter new]];
    }
    
    [[self presenter] bindWithNextButton:[self nextButton]];
    [[self presenter] bindWithNeedButton:[self orderSenseButton]];
    [[self presenter] bindWithTitleLabel:[self titleLabel]
                        descriptionLabel:[self descriptionLabel]];
    [[self presenter] bindWithNavigationItem:[self navigationItem]];
    [[self presenter] setActionDelegate:self];
    
    [self addPresenter:[self presenter]];
}

#pragma mark - HEMNewSenseActionDelegate

- (void)shouldDismissFrom:(HEMNewSensePresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shouldOpenPageTo:(NSString*)page from:(HEMNewSensePresenter*)presenter {
    [HEMSupportUtil openURL:page from:self];
}

- (void)shouldProceedFrom:(HEMNewSensePresenter *)presenter {
    NSString* nextSegueId = nil;
    
    if ([self flow]) {
        nextSegueId = [[self flow] nextSegueIdentifierAfterViewController:self];
    }
    
    if (!nextSegueId) {
        nextSegueId = [HEMOnboardingStoryboard registerSegueIdentifier];
    }
    
    [self performSegueWithIdentifier:nextSegueId sender:self];
}

- (void)shouldProceedToNextSegueWithIdentifier:(NSString*)identifier
                                 nextPresenter:(HEMPresenter*)nextPresenter
                                          from:(HEMNewSensePresenter*)presenter {
    [self performSegueWithIdentifier:identifier sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id nextController = [segue destinationViewController];
    if ([nextController isKindOfClass:[HEMSensePairViewController class]]) {
        HEMSensePairViewController* pairVC = nextController;
        if ([self flow]) {
            HEMPresenter* nextPresenter =
                [[self flow] presenterForNextViewController:pairVC
                                  fromCurrentViewController:self];
            [pairVC setPresenter:(id)nextPresenter];
        }
    }
}

@end
