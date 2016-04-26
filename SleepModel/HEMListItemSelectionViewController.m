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
#import "HEMActivityIndicatorView.h"

@interface HEMListItemSelectionViewController()

// FIXME: this extra navigation bar is a workaround for the mess that is
// the alarm code.  Once we rewrite the alarm code, we should consider
// removing this
@property (weak, nonatomic) IBOutlet UINavigationBar *extraNavigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopConstraint;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicator;
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
    [[self listPresenter] bindWithNavigationBar:[self extraNavigationBar]
                              withTopConstraint:[self navigationBarTopConstraint]];
    [[self listPresenter] bindWithActivityIndicator:[self activityIndicator]];
    [self addPresenter:[self listPresenter]];
}

@end
