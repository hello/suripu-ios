//
//  HEMNoPillViewController.m
//  Sense
//
//  Created by Jimmy Lu on 9/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMNoPillViewController.h"

// TODO (jimmy): we may need this type of information from the server instead
// of hardcoding it here.
static NSString* const kHEMNoPillOrderURL = @"https://order.hello.is/";

@interface HEMNoPillViewController ()

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
    [[[self pairButton] titleLabel] setFont:[UIFont fontWithName:@"Agile-Medium"
                                                            size:20.0f]];
    [[[self pairButton] layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[[self pairButton] layer] setBorderWidth:1.0f];
    [[[self pairButton] layer] setCornerRadius:CGRectGetHeight([[self pairButton] bounds])/2];
    [[self pairButton] setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.1f]];
}

- (void)setupNeedButtonTitle {
    UIFont* font = [UIFont fontWithName:@"Agile-Thin" size:18.0f];
    NSString* needText = NSLocalizedString(@"settings.pill.need-pill", nil);
    NSDictionary* normalAttributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : [UIColor whiteColor],
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

- (void)showNoSenseAlert {
    NSString* title = NSLocalizedString(@"settings.sense.not-found-title", nil);
    NSString* message = NSLocalizedString(@"settings.pill.pair-no-sense-message", nil);
    UIAlertView* messageDialog = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"actions.ok", nil)
                                                  otherButtonTitles:nil];
    [messageDialog show];
}

- (IBAction)pairPill:(id)sender {
    if ([self senseManager] == nil) {
        [self showNoSenseAlert];
    } // TODO: (jimmy): implement it! ... but it requires Sense to be working
}

- (IBAction)needPill:(id)sender {
    // TODO (jimmy): if there's a design for an in-app browser, we can implement
    // it or if there's more time, we will think of something nice
    NSURL* orderURL = [NSURL URLWithString:kHEMNoPillOrderURL];
    [[UIApplication sharedApplication] openURL:orderURL];
}

@end
