//
//  HEMRoomCheckViewController.m
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMRoomCheckViewController.h"
#import "HEMScrollableView.h"
#import "HelloStyleKit.h"
#import "HEMOnboardingUtils.h"
#import "HEMActionButton.h"

static CGFloat const HEMRoomCheckAnimationDuration = 0.5f;

@interface HEMRoomCheckViewController()

@property (weak, nonatomic) IBOutlet HEMScrollableView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet HEMActionButton *continueButton;

@end

@implementation HEMRoomCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContent];
}

- (void)setupContent {
    NSString* desc = NSLocalizedString(@"onboarding.room-check.description", nil);
    NSMutableAttributedString* attrText =
        [[NSMutableAttributedString alloc] initWithString:desc];
    [HEMOnboardingUtils applyCommonDescriptionAttributesTo:attrText];
    
    [[self contentView] addTitle:NSLocalizedString(@"onboarding.room-check.title", nil)];
    [[self contentView] addImage:[HelloStyleKit sensePlacement]];
    [[self contentView] addDescription:attrText];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat shadowOpacity = [[self contentView] scrollRequired]?1.0f:0.0f;
    [[[self buttonContainer] layer] setShadowOpacity:shadowOpacity];
}

- (void)showSensors:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:HEMRoomCheckAnimationDuration
                     animations:^{
                         [[self contentView] setAlpha:0.0f];
                         CGRect contentFrame = [[self contentView] frame];
                         contentFrame.origin.y -= CGRectGetHeight(contentFrame)/2;
                         [[self contentView] setFrame:contentFrame];
                         
                         [[self buttonContainer] setAlpha:0.0f];
                         CGRect containerFrame = [[self buttonContainer] frame];
                         containerFrame.origin.y += CGRectGetHeight(containerFrame)/2;
                         [[self buttonContainer] setFrame:containerFrame];
                     }
                     completion:completion];
}

#pragma mark - Actions

- (IBAction)next:(id)sender {
    [self showSensors:nil];
}

@end
