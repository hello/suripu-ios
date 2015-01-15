    //
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMOnboardingController.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMSupportUtil.h"

@interface HEMOnboardingController()

@property (strong, nonatomic) UIBarButtonItem* leftBarItem;
@property (assign, nonatomic) BOOL enableBack;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint* titleHeightConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint* descriptionTopConstraint;

@end

@implementation HEMOnboardingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEnableBack:YES]; // by default
    [self configureTitle];
    [self configureDescription];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self enableBackButton:[self enableBack]];
}

- (void)configureTitle {
    if ([self isIPhone4Family]) {
        [self setTitle:[[self titleLabel] text]];
        [[self titleHeightConstraint] setConstant:0.0f];
        [[self titleLabel] setHidden:YES];
    } else {
        [[self titleLabel] setTextColor:[HelloStyleKit onboardingTitleColor]];
        [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    }
}

- (void)configureDescription {
    if ([self descriptionLabel] != nil) {
        UIColor* color = [HelloStyleKit onboardingDescriptionColor];
        UIFont* font = [UIFont onboardingDescriptionFont];
        NSMutableAttributedString* attrDesc = [[[self descriptionLabel] attributedText] mutableCopy];
        
        if ([attrDesc length] > 0) {
            [attrDesc addAttributes:@{NSFontAttributeName : font,
                                      NSForegroundColorAttributeName : color}
                              range:NSMakeRange(0, [attrDesc length])];
            
            if ([self isIPhone4Family]) {
                NSMutableParagraphStyle* style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
                [style setAlignment:NSTextAlignmentCenter];
                [attrDesc addAttribute:NSParagraphStyleAttributeName
                                 value:style
                                 range:NSMakeRange(0, [attrDesc length])];
            }
            
            [[self descriptionLabel] setAttributedText:attrDesc];
        } else {
            [[self descriptionLabel] setTextColor:color];
            [[self descriptionLabel] setFont:font];
            
            if ([self isIPhone4Family]) {
                [[self descriptionLabel] setTextAlignment:NSTextAlignmentCenter];
            }
            
        }

    }
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat constant = 10.0f;
    
    if ([self titleHeightConstraint] != nil) {
        [[self descriptionTopConstraint] setConstant:constant];
    } else {
        constant = CGRectGetHeight([[self titleLabel] bounds]);
        [[self descriptionTopConstraint] setConstant:constant];
    }
    
    [super adjustConstraintsForIPhone4];
}

#pragma mark - Nav

- (void)showHelpButton {
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithTitle:@"?"
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(help:)];
    [item setTitlePositionAdjustment:UIOffsetMake(-10.0f, 0.0f)
                       forBarMetrics:UIBarMetricsDefault];
    [item setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor],
        NSFontAttributeName : [UIFont helpButtonTitleFont]
    } forState:UIControlStateNormal];
    [[self navigationItem] setRightBarButtonItem:item];
}

- (void)help:(id)sender {
    [SENAnalytics track:kHEMAnalyticsEventHelp];
    [HEMSupportUtil openHelpFrom:self];
}

- (void)enableBackButton:(BOOL)enable {
    [self setEnableBack:enable];
    
    if (enable) {
        if ([self leftBarItem] != nil) {
            [[self navigationItem] setLeftBarButtonItem:[self leftBarItem]];
        }
    } else {
        [self setLeftBarItem:[[self navigationItem] leftBarButtonItem]];
        [[self navigationItem] setLeftBarButtonItem:nil];
    }
    
    [[self navigationItem] setHidesBackButton:!enable];
    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:enable];
}

@end
