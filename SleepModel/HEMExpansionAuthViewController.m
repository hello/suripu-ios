//
//  HEMExpansionAuthViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMExpansionAuthViewController.h"
#import "HEMExpansionAuthPresenter.h"
#import "HEMConfigurationsPresenter.h"
#import "HEMExpansionService.h"
#import "HEMExpansionsConfigViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMExpansionAuthViewController () <
    HEMExpansionAuthDelegate
>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *toolbarBackButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *toolbarRefreshButton;

@end

@implementation HEMExpansionAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAuthPresenter];
}

- (void)configureAuthPresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    HEMExpansionAuthPresenter* authPresenter =
        [[HEMExpansionAuthPresenter alloc] initWithExpansion:[self expansion]
                                            expansionService:[self expansionService]];
    [authPresenter bindWithWebView:[self webView]];
    [authPresenter bindWithNavigationItem:[self navigationItem]];
    [authPresenter bindWithActivityContainerView:[[self navigationController] view]];
    [authPresenter bindWithToolbar:[self toolbar]
                    containingBack:[self toolbarBackButton]
                           forward:[self toolbarForwardButton]
                        andRefresh:[self toolbarRefreshButton]];
    [authPresenter setDelegate:self];
    [authPresenter setConnectDelegate:[self connectDelegate]];
    [self addPresenter:authPresenter];
}

#pragma mark - HEMExpansionAuthDelegate

- (void)showConfigurations:(NSArray<SENExpansionConfig *> *)configs
              forExpansion:(SENExpansion*)expansion
             fromPresenter:(HEMExpansionAuthPresenter *)authPresenter {
    HEMExpansionsConfigViewController* listVC = [HEMMainStoryboard instantiateExpansionConfigViewController];
    [listVC setExpansion:expansion];
    [listVC setExpansionService:[self expansionService]];
    [listVC setConfigs:configs];
    [listVC setConnectDelegate:[self connectDelegate]];
    [[self navigationController] setViewControllers:@[listVC]];
}

- (void)didCompleteAuthenticationFrom:(HEMExpansionAuthPresenter *)authPresenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelAuthenticationFrom:(HEMExpansionAuthPresenter *)authPresenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
