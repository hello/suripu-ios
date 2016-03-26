//
//  HEMListItemSelectionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemSelectionViewController.h"
#import "HEMListPresenter.h"

@implementation HEMListItemSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self listPresenter] bindWithTableView:[self tableView]];
    [[self listPresenter] bindWithShadowView:[self shadowView]];
    [self addPresenter:[self listPresenter]];
}

@end
