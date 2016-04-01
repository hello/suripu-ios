//
//  HEMListItemSelectionViewController.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListItemSelectionViewController.h"
#import "HEMListPresenter.h"
#import "HEMBaseController+Protected.h"

@interface HEMListItemSelectionViewController()

@property (nonatomic, assign, getter=isFullyConfigured) BOOL fullyConfigured;

@end

@implementation HEMListItemSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self isFullyConfigured]) {
        [[self listPresenter] bindWithShadowView:[self shadowView]];
        [self setFullyConfigured:YES];
    }
}

- (void)configurePresenter {
    [[self listPresenter] bindWithTableView:[self tableView]];
    [self addPresenter:[self listPresenter]];
}

@end
