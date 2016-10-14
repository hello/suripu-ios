#import <SenseKit/SENAuthorizationService.h>

#import "UIFont+HEMStyle.h"

#import "HEMAuthenticationViewController.h"
#import "HEMActionButton.h"
#import "UIColor+HEMStyle.h"
#import "HEMActivityCoverView.h"
#import "HEMNotificationHandler.h"
#import "HEMSupportUtil.h"
#import "HEMConfig.h"

#import "HEMAccountService.h"
#import "HEMOnboardingService.h"
#import "HEMSignInFormPresenter.h"
#import "HEMSignInNavBarPresenter.h"

NSString* const HEMAuthenticationNotificationDidSignIn = @"HEMAuthenticationNotificationDidSignIn";

@interface HEMAuthenticationViewController () <HEMSignInNavBarDelegate, HEMSignInFormDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet HEMActionButton *logInButton;
@property (weak, nonatomic) HEMSignInFormPresenter* formPresenter;
@property (strong, nonatomic) HEMActivityCoverView* activityView;
@property (assign, nonatomic) BOOL signingIn;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;
@property (assign, nonatomic) CGFloat origBottomMargin;

@end

@implementation HEMAuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
    [SENAnalytics track:kHEMAnalyticsEventSignInStart];
}

- (void)configurePresenters {
    HEMOnboardingService* onbService = [HEMOnboardingService sharedService];
    HEMAccountService* acctService = [HEMAccountService sharedService];
    HEMSignInFormPresenter* presenter =
        [[HEMSignInFormPresenter alloc] initWithOnboardingService:onbService
                                                   accountService:acctService];
    [presenter bindWithCollectionView:[self collectionView]
                     bottomConstraint:[self bottomConstraint]];
    [presenter bindWithSignInButton:[self logInButton]];
    [presenter bindWithActivityContainer:[[self navigationController] view]];
    [presenter setDelegate:self];
    [self addPresenter:presenter];
    [self setFormPresenter:presenter];
    
    HEMSignInNavBarPresenter* navBarPresenter = [HEMSignInNavBarPresenter new];
    [navBarPresenter setDelegate:self];
    [navBarPresenter bindWithOnboardingController:self];
    [self addPresenter:navBarPresenter];
}

- (BOOL)wantsShadowView {
    return YES;
}

#pragma mark - HEMSignInFormDelegate

- (void)showErrorTitle:(NSString*)title
               message:(NSString*)message
                  from:(HEMSignInFormPresenter*)presenter {
    [self showMessageDialog:message title:title];
}

#pragma mark - HEMSignInFormNavBarDelegate

- (void)dismissControllerFrom:(HEMSignInNavBarPresenter *)presenter {
    [[self view] endEditing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showForgotPasswordScreenFrom:(HEMSignInNavBarPresenter *)presenter {
    [HEMSupportUtil openURL:[HEMConfig stringForConfig:HEMConfPassResetURL] from:self];
}

@end
