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
#import "HEMBreadcrumbService.h"
#import "HEMHandHoldingService.h"
#import "HEMAlertViewController.h"

@interface HEMAccountViewController () <HEMAccountDelegate>

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) HEMPresenter* accountPresenter;
@property (strong, nonatomic) HEMFacebookService* facebookService;
@property (strong, nonatomic) HEMHandHoldingService* handHoldingService;

@end

@implementation HEMAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [SENAnalytics track:kHEMAnalyticsEventAccount];
}

- (void)configurePresenter {
    HEMAccountService* accountService = [HEMAccountService sharedService];
    SENAccount* account = [accountService account];
    HEMBreadcrumbService* crumbService = [HEMBreadcrumbService sharedServiceForAccount:account];
    HEMFacebookService* facebookService = [HEMFacebookService new];
    HEMHandHoldingService* handHoldingService = [HEMHandHoldingService new];
    HEMAccountPresenter* presenter = [[HEMAccountPresenter alloc] initWithAccountService:accountService
                                                                         facebookService:facebookService
                                                                        healthKitService:[HEMHealthKitService sharedService]
                                                                       breadcrumbService:crumbService
                                                                      handHoldingService:handHoldingService];
    [presenter setDelegate:self];
    [presenter bindWithTableView:[self infoTableView]];
    
    [self setAccountPresenter:presenter];
    [self addPresenter:presenter];
    [self setFacebookService:facebookService];
    [self setHandHoldingService:handHoldingService];
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
    } else if ([controller isKindOfClass:[HEMAlertViewController class]]) {
        HEMAlertViewController* alertVC = (id) controller;
        [alertVC setViewToShowThrough:[self backgroundViewForAlerts]];
        [alertVC showFrom:[self rootViewController]];
    } else if (![controller isKindOfClass:[UINavigationController class]]) {
        controllerToPresenter = [[HEMStyledNavigationViewController alloc] initWithRootViewController:controller];
        [self presentViewController:controllerToPresenter animated:YES completion:nil];
    } else {
        [self presentViewController:controllerToPresenter animated:YES completion:nil];
    }
}

- (void)dismissViewControllerFrom:(HEMAccountPresenter*)presenter
                       completion:(void(^)(void))completion {
    [self dismissViewControllerAnimated:YES completion:completion];
}

@end
