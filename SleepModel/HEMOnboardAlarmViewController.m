//
//  HEMOnboardAlarmViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMOnboardAlarmViewController.h"
#import "HEMBaseController+Protected.h"
#import "HEMScrollableView.h"
#import "HEMOnboardingUtils.h"

@interface HEMOnboardAlarmViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

@end

@implementation HEMOnboardAlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContent];
}

- (void)setupContent {
    
}

@end
