//
//  HEMSetupDoneViewController.m
//  Sense
//
//  Created by Jimmy Lu on 8/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMSetupDoneViewController.h"
#import "HEMActionButton.h"

@interface HEMSetupDoneViewController()

@property (weak, nonatomic) IBOutlet UIImageView *illustrationImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMSetupDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateIllustrationView];
    [self enableBackButton:NO];
}

- (void)updateIllustrationView {
    static NSString* imageKey = @"sense.illustration";
    UIImage* image = [SenseStyle imageWithAClass:[self class]
                                    propertyName:imageKey];
    [[self illustrationImageView] setImage:image];
}

- (IBAction)finish:(id)sender {
    if (![self continueWithFlowBySkipping:NO]) {
        [self completeOnboardingWithoutMessage];
    }
}

@end
