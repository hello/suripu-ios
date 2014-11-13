//
//  HEMGetAppViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/7/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMGetAppViewController.h"
#import "HEMOnboardingUtils.h"

@interface HEMGetAppViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation HEMGetAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubtitle];
}

- (void)setupSubtitle {
    NSString* format = NSLocalizedString(@"setup.get-app.subtitle.format", nil);
    NSString* url = NSLocalizedString(@"setup.get-app.url", nil);
    
    NSArray* args = @[
        [HEMOnboardingUtils boldAttributedText:url withColor:[UIColor blackColor]]
    ];
    
    NSMutableAttributedString* attrSubtitle
        = [[NSMutableAttributedString alloc] initWithFormat:format args:args];
    
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrSubtitle];
    
    [[self subtitleLabel] setAttributedText:attrSubtitle];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGSize constraint = [[self subtitleLabel] bounds].size;
    constraint.height = MAXFLOAT;
    CGSize textSize = [[self subtitleLabel] sizeThatFits:constraint];
    DDLogVerbose(@"get app subtitle height %f", textSize.height);
}

@end
