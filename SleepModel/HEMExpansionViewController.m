//
//  HEMExpansionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMExpansionViewController.h"
#import "HEMActionButton.h"
#import "HEMExpansionService.h"
#import "HEMExpansionPresenter.h"
#import "HEMAlertViewController.h"
#import "HEMExpansionAuthViewController.h"
#import "HEMExpansionConnectDelegate.h"
#import "HEMMainStoryboard.h"
#import "HEMTutorial.h"
#import "HEMExpansionConnectDelegate.h"

@interface HEMExpansionViewController() <
    HEMExpansionDelegate,
    HEMPresenterErrorDelegate,
    HEMExpansionConnectDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *connectButtonView;
@property (weak, nonatomic) IBOutlet HEMActionButton *connectButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomConstraint;
@property (weak, nonatomic) HEMExpansionPresenter* expPresenter;

@end

@implementation HEMExpansionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    HEMExpansionPresenter* presenter =
        [[HEMExpansionPresenter alloc] initWithExpansionService:[self expansionService]
                                                   forExpansion:[self expansion]];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithConnectContainer:[self connectButtonView]
                    andBottomConstraint:[self buttonBottomConstraint]
                             withButton:[self connectButton]];
    [presenter bindWithRootView:[[self rootViewController] view]];
    [presenter setDelegate:self];
    [presenter setErrorDelegate:self];
    
    [self setExpPresenter:presenter];
    [self addPresenter:presenter];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[self navigationController] navigationBar]
        && ![[self expPresenter] hasNavBar]) {
        [[self expPresenter] bindWithNavBar:[[self navigationController] navigationBar]];
    }
}

#pragma mark - HEMExpansionDelegate

- (void)showController:(UIViewController*)controller
         fromPresenter:(HEMExpansionPresenter*)presenter {
    
    if ([[self rootViewController] presentedViewController]) {
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [[self rootViewController] presentViewController:controller
                                                animated:YES
                                              completion:nil];
    }
}

- (void)removedAccessFrom:(HEMExpansionPresenter*)presenter {
    [[self navigationController] popViewControllerAnimated:NO];
}

- (void)showEnableInfoDialogFromPresenter:(HEMExpansionPresenter *)presenter {
    [HEMTutorial showInfoForExpansionFrom:[self navigationController]];
}

- (void)connectExpansionFromPresenter:(HEMExpansionPresenter *)presenter {
    [self performSegueWithIdentifier:[HEMMainStoryboard connectSegueIdentifier] sender:self];
}

#pragma mark - HEMPresenterErrorDelegate

- (void)showCustomerAlert:(HEMAlertViewController *)alert fromPresenter:(HEMPresenter *)presenter {
    [alert setViewToShowThrough:[self backgroundViewForAlerts]];
    [alert showFrom:self];
}

- (void)showErrorWithTitle:(nullable NSString*)title
                andMessage:(NSString*)message
              withHelpPage:(nullable NSString*)helpPage
             fromPresenter:(HEMPresenter*)presenter {
    [self showMessageDialog:message title:title];
}

#pragma mark - HEMExpansionConnectDelegate

- (void)didConnect:(BOOL)connected withExpansion:(SENExpansion *)expansion {
    if (connected) {
        [[self expPresenter] reload:expansion];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id dest = [segue destinationViewController];
    if ([dest isKindOfClass:[UINavigationController class]]) {
        dest = [dest topViewController];
    }
    
    if ([dest isKindOfClass:[HEMExpansionAuthViewController class]]) {
        HEMExpansionAuthViewController* authVC = dest;
        [authVC setExpansion:[self expansion]];
        [authVC setConnectDelegate:self];
        [authVC setExpansionService:[self expansionService]];
    }
}

@end
