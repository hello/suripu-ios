//
//  HEMExpansionListViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMExpansionListViewController.h"
#import "HEMExpansionService.h"
#import "HEMExpansionsListPresenter.h"

@interface HEMExpansionListViewController()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HEMExpansionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)configurePresenter {
    if (![self expansionService]) {
        [self setExpansionService:[HEMExpansionService new]];
    }
    
}

@end
