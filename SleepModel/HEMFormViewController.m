//
//  HEMFormViewController.m
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMFormViewController.h"
#import "HEMFieldTableViewCell.h"

@interface HEMFormViewController ()

@property (weak, nonatomic) IBOutlet UITableView *formTableview;

@end

@implementation HEMFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
}

- (void)configureTableView {
    CGRect frame = CGRectZero;
    frame.size.height = HEMSettingsCellTableMargin;
    [[self formTableview] setTableHeaderView:[[UIView alloc] initWithFrame:frame]];
}

#pragma mark - UITableViewDelegate / DataSource

@end
