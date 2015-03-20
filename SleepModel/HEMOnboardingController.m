    //
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "HEMOnboardingController.h"
#import "HelloStyleKit.h"
#import "HEMBaseController+Protected.h"
#import "HEMSupportUtil.h"
#import "HEMActivityCoverView.h"
#import "HEMOnboardingCache.h"
#import "HEMOnboardingUtils.h"

@interface HEMOnboardingController()

@property (strong, nonatomic) HEMActivityCoverView* activityCoverView;
@property (strong, nonatomic) UIBarButtonItem* leftBarItem;
@property (strong, nonatomic) UIBarButtonItem* cancelItem;
@property (assign, nonatomic) BOOL enableBack;
@property (copy,   nonatomic) NSString* analyticsHelpStep;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint* titleHeightConstraint;
@property (weak,   nonatomic) IBOutlet NSLayoutConstraint* descriptionTopConstraint;
@property (copy,   nonatomic) NSString* helpPage;

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

- (void)showMessageDialog:(NSString*)message title:(NSString*)title {
    [self showMessageDialog:message title:title image:nil withHelpPage:nil];
}

- (void)showMessageDialog:(NSString *)message
                    title:(NSString *)title
                    image:(UIImage*)image
             withHelpPage:(NSString*)helpPage {
    // only show error if user is still on the same screen.  BLE commands, especially
    // can come a long time later than when it should
    if ([[self navigationController] topViewController] == self) {
        [super showMessageDialog:message
                           title:title
                           image:nil
                    withHelpPage:helpPage];
    }
}

#pragma mark - Analytics

- (NSString*)onboardingAnalyticsEventNameFor:(NSString*)event {
    NSString* reusedEvent = event;
    if (![HEMOnboardingUtils hasFinishedOnboarding]
        && ![event hasPrefix:HEMAnalyticsEventOnboardingPrefix]) {
        reusedEvent = [NSString stringWithFormat:@"%@ %@", HEMAnalyticsEventOnboardingPrefix, event];
    }
    return reusedEvent;
}

- (void)trackAnalyticsEvent:(NSString*)event {
    [SENAnalytics track:[self onboardingAnalyticsEventNameFor:event]];
}

- (void)trackAnalyticsEvent:(NSString *)event properties:(NSDictionary*)properties {
    [SENAnalytics track:[self onboardingAnalyticsEventNameFor:event] properties:properties];
}

#pragma mark - Nav

- (void)showHelpButtonForPage:(NSString*)page
         andTrackWithStepName:(NSString*)stepName {
    UIBarButtonItem* item =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"question-mark", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(help:)];
    [item setTitlePositionAdjustment:UIOffsetMake(-10.0f, 0.0f)
                       forBarMetrics:UIBarMetricsDefault];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [HelloStyleKit senseBlueColor],
                                   NSFontAttributeName : [UIFont helpButtonTitleFont]
                                   }
                        forState:UIControlStateNormal];
    
    [[self navigationItem] setRightBarButtonItem:item];
    [self setAnalyticsHelpStep:stepName];
    [self setHelpPage:page];
}

- (void)help:(id)sender {
    NSString* step = [self analyticsHelpStep] ?: @"undefined";
    NSDictionary* properties = @{kHEMAnalyticsEventPropStep : step};
    [SENAnalytics track:kHEMAnalyticsEventOnBHelp properties:properties];
    [HEMSupportUtil openHelpToPage:[self helpPage] fromController:self];
}

- (void)enableBackButton:(BOOL)enable {
    [self setEnableBack:enable];
    
    if (enable) {
        if ([self leftBarItem] != nil) {
            [[self navigationItem] setLeftBarButtonItem:[self leftBarItem]];
            [[self navigationItem] setHidesBackButton:YES];
        } else {
            [[self navigationItem] setHidesBackButton:NO];
        }
    } else {
        [self setLeftBarItem:[[self navigationItem] leftBarButtonItem]];
        [[self navigationItem] setLeftBarButtonItem:nil];
        [[self navigationItem] setHidesBackButton:YES];
    }

    [[[self navigationController] interactivePopGestureRecognizer] setEnabled:enable];
}

- (void)showCancelButtonWithSelector:(SEL)selector {
    NSString* title = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:selector];
    [cancelItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1.0f alpha:0.0f]}
                              forState:UIControlStateDisabled];
    [self setCancelItem:cancelItem];
    [self setLeftBarItem:cancelItem];
    [[self navigationItem] setLeftBarButtonItem:[self cancelItem]];
}

- (SENSenseManager*)manager {
    SENSenseManager* manager = [[SENServiceDevice sharedService] senseManager];
    return manager ? manager : [[HEMOnboardingCache sharedCache] senseManager];
}

#pragma mark - Activity

- (void)showActivityWithMessage:(NSString*)message completion:(void(^)(void))completion {
    if ([self activityCoverView] != nil) {
        [[self activityCoverView] removeFromSuperview];
    }
    
    [self setActivityCoverView:[[HEMActivityCoverView alloc] init]];
    [[self activityCoverView] showInView:[[self navigationController] view] withText:message activity:YES completion:completion];
}

- (void)stopActivityWithMessage:(NSString*)message success:(BOOL)sucess completion:(void(^)(void))completion {
    if (![[self activityCoverView] isShowing]) {
        if (completion) completion ();
    } else {
        [[self activityCoverView] dismissWithResultText:message showSuccessMark:sucess remove:YES completion:^{
            [self setActivityCoverView:nil];
            if (completion) completion ();
        }];
    }
}

- (void)updateActivityText:(NSString*)updateMessage completion:(void(^)(BOOL finished))completion {
    if ([self activityCoverView] == nil) {
        if ([updateMessage length] > 0) {
            [self showActivityWithMessage:updateMessage completion:^{
                if (completion) completion (YES);
            }];
        } else if (completion) {
            completion (YES);
        }
    } else {
        [[self activityCoverView] updateText:updateMessage completion:completion];
    }
}

#pragma mark - Convenience Methods

- (void)stylePrimaryButton:(UIButton*)button
           secondaryButton:(UIButton*)secondaryButton
              withDelegate:(BOOL)hasDelegate {
    
    [[secondaryButton titleLabel] setFont:[UIFont secondaryButtonFont]];
    [secondaryButton setTitleColor:[HelloStyleKit senseBlueColor]
                          forState:UIControlStateNormal];

    if (hasDelegate) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [button setTitle:done forState:UIControlStateNormal];
        [secondaryButton setTitle:cancel forState:UIControlStateNormal];
    }
    
}

@end
