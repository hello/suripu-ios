//
//  HEMWelcomeViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/18/14.
//  Copyright (c) 2014 Delisa Mason. All rights reserved.
//

#import "HEMWelcomeViewController.h"
#import "HEMActionButton.h"
#import "UIView+HEMMotionEffects.h"

@interface HEMWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet HEMActionButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;

@end

@implementation HEMWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self bgImageView] add3DEffectWithBorder:10.0f];
    [[self signupButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[self signinButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
