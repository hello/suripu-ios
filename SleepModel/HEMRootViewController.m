//
//  HEMRootViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/6/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENServiceQuestions.h>
#import <SenseKit/SENQuestion.h>

#import "UIFont+HEMStyle.h"
#import "UIView+HEMSnapshot.h"

#import "HEMRootViewController.h"
#import "HEMSleepQuestionsViewController.h"
#import "HEMAlertController.h"
#import "HEMOnboardingUtils.h"
#import "HEMSupportUtil.h"
#import "HEMActionView.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"

@interface HEMRootViewController () <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) HEMAlertController* supportOptionController;

@property (strong, nonatomic) HEMActionView* questionActionView;
@property (strong, nonatomic) id questionObserver;
@property (strong, nonatomic) id signOutObserver;
@property (weak,   nonatomic) SENQuestion* displayedQuestion;

@end

@implementation HEMRootViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self questionObserver] == nil) {
        [self handleSleepQuestions];
    }
    if ([self signOutObserver] == nil) {
        [self handleUserSigningOut];
    }
}

#pragma mark - Shake to Show Support Options

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [self showSupportOptions];
    }
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now
    
    // can't simply cache the alertcontroller and not recreate it as the presentingcontroller
    // is cached within it, which may be different each time this is called
    UIViewController* presentingController = [self presentedViewController] ?: self;
    NSString* title = NSLocalizedString(@"support.options.title", nil);
    HEMAlertController* sheet = [[HEMAlertController alloc] initWithTitle:title
                                                                  message:nil
                                                                    style:HEMAlertControllerStyleSheet
                                                     presentingController:presentingController];
    
    [self addContactSupportOptionTo:sheet];
    [self addResetCheckpointOptionTo:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet]; // need to hold on to it otherwise action callbacks will crash
    [[self supportOptionController] show];
}

- (void)addContactSupportOptionTo:(HEMAlertController*)sheet {
    UIViewController* presentingController = [self presentedViewController] ?: self;
    
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.contact-support", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [HEMSupportUtil contactSupportFrom:presentingController mailDelegate:strongSelf];
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

- (void)addResetCheckpointOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"support.option.reset", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if ([[strongSelf presentedViewController] isKindOfClass:[UINavigationController class]]) {
                UINavigationController* onboardingVC = (UINavigationController*)[strongSelf presentedViewController];
                UIViewController* startController = [HEMOnboardingUtils onboardingControllerForCheckpoint:HEMOnboardingCheckpointStart authorized:NO];
                if (![[onboardingVC topViewController] isKindOfClass:[startController class]]) {
                    [onboardingVC setViewControllers:@[startController] animated:YES];
                }
            }
            [strongSelf setSupportOptionController:nil];
            [SENAuthorizationService deauthorize];
        }
    }];
}

- (void)addCancelOptionTo:(HEMAlertController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addActionWithText:NSLocalizedString(@"actions.cancel", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setSupportOptionController:nil];
        }
    }];
}

#pragma mark Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Questions

- (void)handleSleepQuestions {
    __weak typeof(self) weakSelf = self;
    self.questionObserver =
        [[SENServiceQuestions sharedService] listenForNewQuestions:^(NSArray *questions) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [questions count] > 0) {
                [strongSelf performSelector:@selector(showQuestionAlertFor:)
                                 withObject:questions
                                 afterDelay:2.0f];
            }
        }];
}

- (void)showQuestionAlertFor:(NSArray*)questions {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showQuestionAlertFor:)
                                               object:nil];
    
    if ([self questionActionView] != nil
        || [questions count] == 0
        || ![SENAuthorizationService isAuthorized]) {
        return;
    }
    
    // just show the first question as an alert
    [self setDisplayedQuestion:questions[0]];
    NSString* firstQuestion = [[self displayedQuestion] question];
    DDLogVerbose(@"showing question %@", firstQuestion);
    NSMutableParagraphStyle* paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paraStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont actionViewMessageFont],
                                 NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSParagraphStyleAttributeName : paraStyle};
    
    NSAttributedString* attrQuestion =
        [[NSAttributedString alloc] initWithString:firstQuestion attributes:attributes];
    
    [self setQuestionActionView:[[HEMActionView alloc] initWithTitle:nil message:attrQuestion]];
    
    [[[self questionActionView] cancelButton] addTarget:self
                                                 action:@selector(skipQuestion:)
                                       forControlEvents:UIControlEventTouchUpInside];
    [[[self questionActionView] okButton] addTarget:self
                                             action:@selector(showQuestions:)
                                   forControlEvents:UIControlEventTouchUpInside];
    
    NSString* answerText = [NSLocalizedString(@"actions.answer", nil) uppercaseString];
    [[[self questionActionView] okButton] setTitle:answerText forState:UIControlStateNormal];
    
    [[self questionActionView] showInView:[self view] animated:YES completion:nil];
}

- (void)hideQuestionsAlert:(BOOL)animated completion:(void(^)(void))completion{

    if ([self questionActionView] != nil) {
        [[self questionActionView] dismiss:animated completion:^{
            [self setQuestionActionView:nil];
            if (completion) completion ();
        }];
        
    }
}

#pragma mark Question Actions

- (void)skipQuestion:(id)sender {
    // optimistically skip the question
    SENServiceQuestions* svc = [SENServiceQuestions sharedService];
    [svc skipQuestion:[self displayedQuestion] completion:nil];
    [self hideQuestionsAlert:YES completion:nil];
}

- (void)showQuestions:(id)sender {
    if ([self presentedViewController] != nil) return;
    
    UIImage* snapshot = [[self view] blurredSnapshotWithTint:[HelloStyleKit sleepQuestionBgColor]];
    
    [[self questionActionView] dismiss:YES completion:^{
        NSArray* questions = [[SENServiceQuestions sharedService] todaysQuestions];
        
        HEMSleepQuestionsViewController* questionsVC =
        (HEMSleepQuestionsViewController*)[HEMMainStoryboard instantiateSleepQuestionsViewController];
        [questionsVC setQuestions:questions];
        [questionsVC setBgImage:snapshot];
        [questionsVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        [self presentViewController:questionsVC animated:YES completion:nil];
        
        [self setQuestionActionView:nil];
    }];
}

#pragma mark - Sign Out

- (void)handleUserSigningOut {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(showQuestionAlertFor:)
                                               object:nil];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    __weak typeof(self) weakSelf = self;
    self.signOutObserver =
        [center addObserverForName:SENAuthorizationServiceDidDeauthorizeNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                                    if (strongSelf) {
                                        [strongSelf hideQuestionsAlert:NO completion:nil];
                                    }
                             }];
}

#pragma mark - Clean Up

- (void)dealloc {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    if ([self signOutObserver] == nil) {
        [center removeObserver:[self signOutObserver]];
    }
    
    if ([self questionObserver] == nil) {
        [center removeObserver:[self questionObserver]];
    }
}

@end
