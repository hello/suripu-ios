//
//  HEMExpansionListViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMExpansionListViewController.h"
#import "HEMExpansionViewController.h"
#import "HEMExpansionService.h"
#import "HEMExpansionListPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMMainStoryboard.h"

@interface HEMExpansionListViewController() <HEMExpansionActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) SENExpansion* selectedExpansion;

@end

@implementation HEMExpansionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    
    HEMExpansionListPresenter* presenter =
        [[HEMExpansionListPresenter alloc] initWithExpansionService:[self expansionService]];
    [presenter bindWithTableView:[self tableView]];
    [presenter bindWithShadowView:[self shadowView]];
    [presenter bindWithActivityIndicator:[self activityIndicator]];
    [presenter setActionDelegate:self];
    
    [self addPresenter:presenter];
}

#pragma mark - HEMExpansionActionDelegate

- (void)shouldShowExpansion:(SENExpansion *)expansion
              fromPresenter:(HEMExpansionListPresenter *)presenter {
    [self setSelectedExpansion:expansion];
    [self performSegueWithIdentifier:[HEMMainStoryboard expansionSegueIdentifier]
                              sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = [segue destinationViewController];
    if ([destVC isKindOfClass:[HEMExpansionViewController class]]) {
        HEMExpansionViewController* expVC = destVC;
        [expVC setExpansion:[self selectedExpansion]];
        [expVC setExpansionService:[self expansionService]];
    }
}

@end
