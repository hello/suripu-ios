//
//  HEMFormViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFormViewController.h"
#import "HEMFormPresenter.h"

@interface HEMFormViewController () <HEMFormDelegate>

@property (weak, nonatomic) IBOutlet UITableView *formTableview;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonItem;

@end

@implementation HEMFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
}

- (void)configurePresenter {
    [[self presenter] bindWithTableView:[self formTableview]];
    [[self presenter] bindWithSaveItem:[self saveButtonItem]];
    [[self presenter] setTitle:[self title]];
    [[self presenter] setDelegate:self];
    [self addPresenter:[self presenter]];
}

#pragma mark - Form Delegate

- (void)showErrorTitle:(NSString*)title
               message:(NSString*)message
         fromPresenter:(HEMFormPresenter*)presenter {
    [self showMessageDialog:message title:title];
}

- (void)dismissFrom:(HEMFormPresenter*)presenter {
    [[self navigationController] popViewControllerAnimated:NO];
}

@end
