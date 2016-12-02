    //
//  HEMOnboardingController.m
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENServiceDevice.h>

#import "UIBarButtonItem+HEMNav.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"

#import "HEMOnboardingController.h"
#import "HEMSupportUtil.h"
#import "HEMActivityCoverView.h"
#import "HEMOnboardingService.h"
#import "HEMScreenUtils.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMAlertViewController.h"
#import "HEMStyledNavigationViewController.h"

static CGFloat const HEMOnboardingCompletionDelay = 2.0f;

@interface HEMOnboardingController()

@property (strong, nonatomic) HEMActivityCoverView* activityCoverView;
@property (assign, nonatomic) BOOL enableBack;
@property (copy,   nonatomic) NSString* analyticsHelpStep;
@property (copy,   nonatomic) NSString* helpPage;
@property (assign, nonatomic, getter=isVisible) BOOL visible;

@end

@implementation HEMOnboardingController

+ (UIViewController*)onboardingRootViewController {
    UIStoryboard* onboardingStoryboard = [UIStoryboard storyboardWithName:@"Onboarding"
                                                                   bundle:[NSBundle mainBundle]];
    return [onboardingStoryboard instantiateInitialViewController];
}

+ (UINavigationController*)containedOnboardingController:(UIViewController*)controller {
    if ([controller isKindOfClass:[UINavigationController class]] || !controller) {
        return (id)controller;
    }
    return [[HEMStyledNavigationViewController alloc] initWithRootViewController:controller];
}

+ (UIViewController*)controllerForCheckpoint:(HEMOnboardingCheckpoint)checkpoint force:(BOOL)force {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    if (![service isAuthorizedUser] || force) {
        [service resetOnboardingCheckpoint];
        return [self onboardingRootViewController];
    }
    
    switch (checkpoint) {
        case HEMOnboardingCheckpointStart:
            return [self onboardingRootViewController];
        case HEMOnboardingCheckpointAccountCreated:
            return [self containedOnboardingController:[HEMOnboardingStoryboard instantiateDobViewController]];
        case HEMOnboardingCheckpointAccountDone:
            return [self containedOnboardingController:[HEMOnboardingStoryboard instantiateSenseSetupViewController]];
        case HEMOnboardingCheckpointSenseDone:
            return [self containedOnboardingController:[HEMOnboardingStoryboard instantiatePillDescriptionViewController]];
        case HEMOnboardingCheckpointPillFinished:
        case HEMOnboardingCheckpointPillDone:
            return [self containedOnboardingController:[HEMOnboardingStoryboard instantiateSenseColorsViewController]];
        case HEMOnboardingCheckpointSenseColorsViewed:
        case HEMOnboardingCheckpointSenseColorsFinished:
        default:
            return nil;
    }
}

- (BOOL)wantsShadowView {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEnableBack:YES]; // by default
    [self configureTitle];
    [self configureDescription];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self enableBackButton:[self enableBack]];
    [self setVisible:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // set visibility before it's actually disappeared in case anything is
    // trying to present something while it's going away
    [self setVisible:NO];
}

- (void)configureTitle {
    if (HEMIsIPhone4Family()) {
        [self setTitle:[[self titleLabel] text]];
        [[self titleHeightConstraint] setConstant:0.0f];
        [[self titleLabel] setHidden:YES];
    } else {
        [[self titleLabel] setTextColor:[UIColor boldTextColor]];
        [[self titleLabel] setFont:[UIFont h5]];
    }
}

- (void)configureDescription {
    if ([self descriptionLabel] != nil) {
        UIColor* color = [UIColor grey5];
        UIFont* font = [UIFont body];
        NSMutableAttributedString* attrDesc = [[[self descriptionLabel] attributedText] mutableCopy];
        
        if ([attrDesc length] > 0) {
            [attrDesc addAttributes:@{NSFontAttributeName : font,
                                      NSForegroundColorAttributeName : color}
                              range:NSMakeRange(0, [attrDesc length])];
            
            if (HEMIsIPhone4Family()) {
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
            
            if (HEMIsIPhone4Family()) {
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
        constant = CGRectGetMinY([[self descriptionLabel] frame]);
        [[self descriptionTopConstraint] setConstant:constant];
    }
    
    [super adjustConstraintsForIPhone4];
}

#pragma mark - Attributes

- (void)applyCommonDescriptionAttributesTo:(NSMutableAttributedString*)attrText {
    UIFont* font = [UIFont body];
    UIColor* color = [UIColor grey5];
    
    // avoid overriding any substrings that may already have attributes set
    [attrText enumerateAttributesInRange:NSMakeRange(0, [attrText length])
                                 options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                              usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                  if ([attrs valueForKey:NSFontAttributeName] == nil) {
                                      [attrText addAttribute:NSFontAttributeName
                                                       value:font
                                                       range:range];
                                  }
                                  
                                  if ([attrs valueForKey:NSForegroundColorAttributeName] == nil) {
                                      [attrText addAttribute:NSForegroundColorAttributeName
                                                       value:color
                                                       range:range];
                                  }
                                  
                              }];
}

- (NSAttributedString*)boldAttributedText:(NSString*)text {
    return [self boldAttributedText:text withColor:nil];
}

- (NSAttributedString*)boldAttributedText:(NSString *)text withColor:(UIColor*)color {
    UIFont* font = [UIFont body];
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [attributes setValue:font forKey:NSFontAttributeName];
    
    if (color) {
        [attributes setValue:color forKey:NSForegroundColorAttributeName];
    } else {
        [attributes setValue:[UIColor grey6] forKey:NSForegroundColorAttributeName];
    }
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Alerts

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
    if ([self flow]) {
        NSString* prefix = [[self flow] analyticsEventPrefix];
        if (![event hasPrefix:prefix]) {
            reusedEvent = [NSString stringWithFormat:@"%@ %@", prefix, event];
        }
    } else if (![[HEMOnboardingService sharedService] hasFinishedOnboarding]) {
        if (![event hasPrefix:HEMAnalyticsEventOnboardingPrefix]) {
            reusedEvent = [NSString stringWithFormat:@"%@ %@",
                           HEMAnalyticsEventOnboardingPrefix, event];
        }
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
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"helpIconSmall"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(help:)];
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
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:title image:nil target:self action:selector];
    [self useCancelBarButtonItem:cancelItem];
}

- (void)showBackButtonAsCancelWithSelector:(SEL)action {
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:nil
                                                                 image:[UIImage imageNamed:@"backIcon"]
                                                                target:self
                                                                action:action];
    [self useCancelBarButtonItem:cancelItem];
}

- (void)useCancelBarButtonItem:(UIBarButtonItem*)cancelItem {
    [self setCancelItem:cancelItem];
    [self setLeftBarItem:cancelItem];
    [[self navigationItem] setLeftBarButtonItem:[self cancelItem]];
}

- (SENSenseManager*)manager {
    return [[HEMOnboardingService sharedService] currentSenseManager];
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
    } else if (![[[[self activityCoverView] activityLabel] text] isEqualToString:updateMessage]) {
        [[self activityCoverView] updateText:updateMessage completion:completion];
    } else if (completion) {
        completion (YES);
    } // else, do nothing
}

#pragma mark - Convenience Methods

- (void)stylePrimaryButton:(UIButton*)button
           secondaryButton:(UIButton*)secondaryButton
              withDelegate:(BOOL)hasDelegate {
    
    [[secondaryButton titleLabel] setFont:[UIFont button]];
    [secondaryButton setTitleColor:[UIColor tintColor]
                          forState:UIControlStateNormal];

    if (hasDelegate) {
        NSString* done = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [button setTitle:done forState:UIControlStateNormal];
        [secondaryButton setTitle:cancel forState:UIControlStateNormal];
    }
    
}

#pragma mark - Flow

- (void)endFlow:(NSString*)doneMessage {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    
    if (!doneMessage) {
        [service notifyOfOnboardingCompletion];
    } else {
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[[self navigationController] view]
                        withText:doneMessage
                     successMark:YES
                      completion:^{
                          int64_t delay = (int64_t) (HEMOnboardingCompletionDelay*NSEC_PER_SEC);
                          dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay);
                          dispatch_after(time, dispatch_get_main_queue(), ^{
                              [service notifyOfOnboardingCompletion];
                          });
                      }];
    }

}

- (void)completeOnboarding {
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    
    [SENAnalytics track:HEMAnalyticsEventOnbEnd];
    [service markOnboardingAsComplete];

    HEMActivityCoverView* activityView = [HEMActivityCoverView new];
    [activityView showInView:[[self navigationController] view]
                    withText:NSLocalizedString(@"onboarding.end-message.well-done", nil)
                 successMark:YES
                  completion:^{
                      int64_t delay = (int64_t) (HEMOnboardingCompletionDelay*NSEC_PER_SEC);
                      dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay);
                      dispatch_after(time, dispatch_get_main_queue(), ^{
                          [service notifyOfOnboardingCompletion];
                      });
                  }];
}

- (void)completeOnboardingWithoutMessage {
    [SENAnalytics track:HEMAnalyticsEventOnbEnd];
    
    HEMOnboardingService* service = [HEMOnboardingService sharedService];
    [service markOnboardingAsComplete];
    [service notifyOfOnboardingCompletion];
}

- (BOOL)continueWithFlowBySkipping:(BOOL)skip {
    BOOL canHandle = NO;
    if ([self flow]) {
        // first check if we can use a segue
        NSString* nextSegueId = [[self flow] nextSegueIdentifierAfter:self skip:skip];
        if (nextSegueId) {
            canHandle = YES;
            [self performSegueWithIdentifier:nextSegueId sender:nil];
        } else {
            // second, see if we should replace nav stack with current controller
            UIViewController* nextController = [[self flow] controllerToSwapInAfter:self skip:skip];
            if (nextController) {
                canHandle = YES;
                [[self navigationController] setViewControllers:@[nextController] animated:YES];
            }
        }
        
        if (!canHandle && [[self flow] shouldCompleteFlowAfter:self]) {
            canHandle = YES;
        }
    }
    return canHandle;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController* nextController = [segue destinationViewController];
    [self prepareViewControllerForNextStep:nextController];
}

- (void)prepareViewControllerForNextStep:(UIViewController*)nextController {
    if ([self flow] && [nextController isKindOfClass:[HEMOnboardingController class]]) {
        [[self flow] prepareNextController:(id)nextController fromController:self];
    }
}

@end
