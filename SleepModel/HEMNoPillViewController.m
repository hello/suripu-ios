//
//  HEMNoPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMNoPillViewController.h"
#import "HEMPillPairViewController.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMSupportUtil.h"

@interface HEMNoPillViewController () <HEMPillPairDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *pairButton;
@property (weak, nonatomic) IBOutlet UIButton *needButton;

@end

@implementation HEMNoPillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPairButton];
    [self setupNeedButtonTitle];
}

- (void)setupPairButton {
    [[[self pairButton] layer] setBorderColor:[[[self pairButton] titleColorForState:UIControlStateNormal] CGColor]];
    [[[self pairButton] layer] setBorderWidth:1.0f];
    [[[self pairButton] layer] setCornerRadius:CGRectGetHeight([[self pairButton] bounds])/2];
    [[self pairButton] setBackgroundColor:[[self view] backgroundColor]];
}

- (void)setupNeedButtonTitle {
    UIFont* font = [[[self needButton] titleLabel] font];
    NSString* needText = NSLocalizedString(@"settings.pill.need-pill", nil);
    NSDictionary* normalAttributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : [[self needButton] titleColorForState:UIControlStateNormal],
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)
    };
    NSDictionary* highlightedAttributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0f alpha:0.5f]
    };
    
    NSMutableAttributedString* normalTitle =
    [[NSMutableAttributedString alloc] initWithString:needText attributes:normalAttributes];
    
    NSMutableAttributedString* highlightedTitle =
    [[NSMutableAttributedString alloc] initWithString:needText
                                           attributes:highlightedAttributes];
    
    [[self needButton] setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [[self needButton] setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
}

- (IBAction)pairPill:(id)sender {
    HEMPillPairViewController* pairVC =
        (HEMPillPairViewController*) [HEMOnboardingStoryboard instantiatePillPairViewController];
    [pairVC setDelegate:self];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:pairVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)needPill:(id)sender {
    [HEMSupportUtil openOrderFormFrom:self];
}

#pragma mark - HEMPillPairDelegate

- (void)didPairWithPillFrom:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        [[self navigationController] popViewControllerAnimated:NO];
    }];
}

- (void)didCancelPairing:(HEMPillPairViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
