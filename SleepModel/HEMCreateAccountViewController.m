//
//  HEMCreateAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCreateAccountViewController.h"
#import "HEMAlertViewController.h"
#import "HEMNewAccountPresenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingService.h"
#import "HEMBluetoothUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"
#import "HEMFacebookService.h"
#import "HEMAccountService.h"

@interface HEMCreateAccountViewController () <HEMNewAccountPresenterDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet HEMActionButton *nextButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) HEMFacebookService* fbService;
@property (strong, nonatomic) HEMAccountService* accountService;

@end

@implementation HEMCreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
    [self trackAnalyticsEvent:HEMAnalyticsEventAccount];
}

- (void)configurePresenters {
    HEMAccountService* accountService = [HEMAccountService new];
    HEMFacebookService* fbService = [HEMFacebookService new];
    HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
    HEMNewAccountPresenter* presenter =
        [[HEMNewAccountPresenter alloc] initWithOnboardingService:onbService
                                                  facebookService:fbService
                                                   accountService:accountService];
    
    [presenter bindWithCollectionView:[self collectionView]
                  andBottomConstraint:[self bottomConstraint]];
    [presenter bindWithNextButton:[self nextButton]];
    [presenter bindWithActivityContainerView:[[self navigationController] view]];
    [presenter setDelegate:self];
    [self setFbService:fbService];
    [self setAccountService:accountService];
    [self addPresenter:presenter];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[self presenters] firstObject] bindWithShadowView:[self shadowView]];
}

- (BOOL)wantsShadowView {
    return YES;
}

#pragma mark - Presenter Delegate

- (void)showSupportPageWithSlug:(NSString*)slug {
    [HEMSupportUtil openHelpToPage:slug fromController:self];
}

- (void)showError:(NSString *)errorMessage
            title:(NSString *)title
             from:(HEMNewAccountPresenter *)presenter {
    [self showMessageDialog:errorMessage title:title];
}

- (void)proceedFrom:(HEMNewAccountPresenter *)presenter {
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(proceedFrom:)
                   withObject:presenter
                   afterDelay:0.1f];
        return;
    }
    
    NSString* segueId =
        ![HEMBluetoothUtils isBluetoothOn] ?
        [HEMOnboardingStoryboard signupToNoBleSegueIdentifier] :
        [HEMOnboardingStoryboard moreInfoSegueIdentifier];
    
    [self performSegueWithIdentifier:segueId sender:self];
}

- (void)showController:(UIViewController *)controller from:(HEMNewAccountPresenter *)presenter {
    if ([controller isKindOfClass:[HEMAlertViewController class]]) {
        HEMAlertViewController* alertVC = (id) controller;
        [alertVC setViewToShowThrough:[self backgroundViewForAlerts]];
        [alertVC showFrom:self];
    } else {
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)dismissViewControllerFrom:(HEMNewAccountPresenter*)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
