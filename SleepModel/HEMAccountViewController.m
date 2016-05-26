//
//  HEMAccountViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/2/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMAccountViewController.h"
#import "HEMAccountPresenter.h"
#import "HEMAccountService.h"
#import "HEMRootViewController.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMAlertViewController.h"
#import "HEMFormViewController.h"
#import "HEMHealthKitService.h"
#import "HEMFacebookService.h"

@interface HEMAccountViewController () <HEMAccountDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) HEMPresenter* accountPresenter;
@property (strong, nonatomic) HEMFacebookService* facebookService;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [SENAnalytics track:kHEMAnalyticsEventAccount];
}

- (void)configurePresenter {
    HEMFacebookService* facebookService = [HEMFacebookService new];
    HEMAccountPresenter* presenter = [[HEMAccountPresenter alloc] initWithAccountService:[HEMAccountService sharedService]
                                                                         facebookService:facebookService
                                                                        healthKitService:[HEMHealthKitService sharedService]];
    [presenter setDelegate:self];
    [presenter bindWithTableView:[self infoTableView]];
    
    [self setAccountPresenter:presenter];
    [self addPresenter:presenter];
    [self setFacebookService:facebookService];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    if (parent) {
        // shadow view depends on the navigation controller, which is
        // not set on viewDidLoad
        [[self accountPresenter] bindWithShadowView:[self shadowView]];
    }
}

#pragma mark - HEMAccountDelegate

- (UIViewController*)mainControllerFor:(HEMAccountPresenter*)presenter {
    return self;
}

- (void)showErrorTitle:(NSString *)title
               message:(NSString *)message
                  from:(HEMAccountPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

- (void)showSignOutConfirmation:(NSString *)title
                       messasge:(NSString *)message
                         action:(HEMAccountSignOutHandler)action
                           from:(HEMAccountPresenter *)presenter {
    
    HEMAlertViewController *dialogVC =
        [[HEMAlertViewController alloc] initBooleanDialogWithTitle:title
                                                           message:message
                                                     defaultsToYes:YES
                                                            action:action];
    
    [dialogVC setViewToShowThrough:[self backgroundViewForAlerts]];
    [dialogVC showFrom:self];
}

- (void)presentViewController:(UIViewController *)controller from:(HEMAccountPresenter *)presenter {
    UIViewController* controllerToPresenter = controller;
    if ([controller isKindOfClass:[UIAlertController class]]) {
        [[self rootViewController] presentViewController:controllerToPresenter animated:YES completion:nil];
    } else if ([controller isKindOfClass:[HEMFormViewController class]]) {
        [[self navigationController] pushViewController:controller animated:YES];
    } else if (![controller isKindOfClass:[UINavigationController class]]) {
        controllerToPresenter = [[HEMStyledNavigationViewController alloc] initWithRootViewController:controller];
        [self presentViewController:controllerToPresenter animated:YES completion:nil];
    } else {
        [self presentViewController:controllerToPresenter animated:YES completion:nil];
    }
}

- (void)dismissViewControllerFrom:(HEMAccountPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
