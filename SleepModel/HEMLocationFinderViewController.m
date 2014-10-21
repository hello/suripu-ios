
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"
#import "HEMLocationCenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HelloStyleKit.h"

static CGFloat const kHEMLocationFinderAnimationDuration = 0.25f;
static CGFloat const kHEMLocationFinderThankyouDisplayTime = 1.0f;

@interface HEMLocationFinderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic)   IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic)   IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UILabel *thankLabel;
@property (weak, nonatomic) IBOutlet UILabel *youLabel;
@property (nonatomic, copy)   NSString* locationTxId;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locateButtonWidthConstraint;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[super navigationItem] setHidesBackButton:YES];
    [SENAnalytics track:kHEMAnalyticsEventOnBLocation];
}

#pragma - Activity

- (void)showActivity {
    [[self skipButton] setEnabled:NO];
    [[self locationButton] showActivityWithWidthConstraint:[self locateButtonWidthConstraint]];
}

- (void)stopActivity {
    [[self skipButton] setEnabled:YES];
    [[self locationButton] stopActivity];
}

#pragma mark - Actions

- (IBAction)requestLocation:(id)sender {
    [self showActivity];
    
    NSError* error = nil;
    __weak typeof(self) weakSelf = self;
    self.locationTxId =
        [[HEMLocationCenter sharedCenter] locate:&error success:^BOOL(double lat, double lon, double accuracy) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                SENAccount* account = [[HEMUserDataCache sharedUserDataCache] account];
                [account setLatitude:@(lat)];
                [account setLongitude:@(lon)];
                
                [strongSelf stopActivity];
                [strongSelf setLocationTxId:nil];
                [strongSelf uploadCollectedData:YES];
                [strongSelf sayThankyouBeforeLeaving];
                [strongSelf trackPermission:NO error:nil];
            }
            return NO;
        } failure:^BOOL(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf stopActivity];
                [strongSelf showLocationError:error];
                [strongSelf setLocationTxId:nil];
                [strongSelf trackPermission:NO error:error];
            }
            return NO;
        }];
    
    if (error != nil) {
        [self stopActivity];
        [self showLocationError:error];
    }
}

- (IBAction)skipRequestingLocation:(id)sender {
    [self uploadCollectedData:YES];
    [self sayThankyouBeforeLeaving];
    [self trackPermission:YES error:nil];
}

#pragma mark - Tracking Actions

- (void)trackPermission:(BOOL)skipped error:(NSError*)error {
    NSString* status = nil;
    
    if (skipped) {
        status = kHEManaltyicsEventStatusSkipped;
    } else if (error == nil) {
        status = kHEManaltyicsEventStatusEnabled;
    } else if ([error code] == HEMLocationErrorCodeNotAuthorized) {
        status = kHEManaltyicsEventStatusDenied;
    } else if ([error code] == HEMLocationErrorCodeNotEnabled) {
        status = kHEManaltyicsEventStatusDisabled;
    }
    
    NSDictionary* properties = status != nil ? @{kHEManaltyicsEventPropStatus : status} : nil;
    [SENAnalytics track:kHEMAnalyticsEventPermissionLoc properties:properties];
}

#pragma mark - Alerts

- (NSString*)errorMessageForLocationError:(NSError*)error {
    NSString* errorMessage = nil;
    switch ([error code]) {
        case HEMLocationErrorCodeNotAuthorized:
        case HEMLocationErrorCodeNotEnabled: {
            errorMessage = NSLocalizedString(@"location.error.not-enabled", nil);
            break;
        }
        default: {
            errorMessage = NSLocalizedString(@"location.error.weak-signal", nil);
            break;
        }
    }
    return errorMessage;
}

- (void)showLocationError:(NSError*)error {
    [self showMessageDialog:[self errorMessageForLocationError:error]
                      title:NSLocalizedString(@"location.error.title", nil)];
}

#pragma mark - Finishing Up

- (void)uploadCollectedData:(BOOL)retry {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount updateAccount:[[HEMUserDataCache sharedUserDataCache] account]
                 completionBlock:^(id data, NSError *error) {
                     DLog(@"update completed with error %@", error);
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     if (!strongSelf) return;
                     if (error != nil && retry) {
                         DLog(@"failed to update account with user information");
                         [strongSelf uploadCollectedData:NO];
                     } // TODO (jimmy): else if error, no retry, what should we do?
                 }];
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard senseSetupSegueIdentifier]
                              sender:self];
}

- (void)animateThankyou:(void(^)(BOOL finished))completion {
    [UIView animateWithDuration:kHEMLocationFinderAnimationDuration
                     animations:^{
                         [[self thankLabel] setAlpha:1.0f];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:kHEMLocationFinderAnimationDuration
                                          animations:^{
                                              [[self youLabel] setAlpha:1.0f];
                                          }
                                          completion:completion];
                     }];
}

- (void)sayThankyouBeforeLeaving {
    [UIView animateWithDuration:kHEMLocationFinderAnimationDuration
                     animations:^{
                         [[self titleLabel] setAlpha:0.0f];
                         [[self mapImageView] setAlpha:0.0f];
                         [[self locationButton] setAlpha:0.0f];
                         [[self skipButton] setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [self animateThankyou:^(BOOL finished) {
                             [self performSelector:@selector(next)
                                        withObject:nil
                                        afterDelay:kHEMLocationFinderThankyouDisplayTime];
                         }];
                     }];
}

#pragma mark - Clean Up

- (void)dealloc {
    if ([self locationTxId] != nil) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
}

@end
