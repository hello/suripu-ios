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
#import "HEMListItemSelectionViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMExpansionAuthViewController () <
    HEMExpansionAuthDelegate,
    HEMListDelegate
>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

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
    [authPresenter setDelegate:self];
    [authPresenter setConnectDelegate:[self connectDelegate]];
    [self addPresenter:authPresenter];
}

#pragma mark - HEMExpansionAuthDelegate

- (void)showConfigurations:(NSArray<SENExpansionConfig *> *)configs
             fromPresenter:(HEMExpansionAuthPresenter *)authPresenter {
    HEMListItemSelectionViewController* listVC = [HEMMainStoryboard instantiateListItemViewController];
    
    HEMConfigurationsPresenter* presenter =
    [[HEMConfigurationsPresenter alloc] initWithConfigs:configs
                                           forExpansion:[self expansion]
                                       expansionService:[self expansionService]];
    [presenter setConnectDelegate:[self connectDelegate]];
    [listVC setListPresenter:presenter];
    
    [[self navigationController] setViewControllers:@[listVC]];
    
}

- (void)didCompleteAuthenticationFrom:(HEMExpansionAuthPresenter *)authPresenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelAuthenticationFrom:(HEMExpansionAuthPresenter *)authPresenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
