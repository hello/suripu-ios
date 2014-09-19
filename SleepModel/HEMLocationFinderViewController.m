
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"
#import "HEMLocationCenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"

@interface HEMLocationFinderViewController ()

@property (nonatomic, copy) NSString* locationTxId;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locateButtonWidthConstraint;

@end

@implementation HEMLocationFinderViewController

- (void)showActivity {
    [[self skipButton] setEnabled:NO];
    [[self locationButton] showActivityWithWidthConstraint:[self locateButtonWidthConstraint]];
}

- (void)stopActivity {
    [[self skipButton] setEnabled:YES];
    [[self locationButton] stopActivity];
}

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
                [strongSelf next];
            }
            return NO;
        } failure:^BOOL(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf stopActivity];
                [strongSelf showLocationError:error];
                [strongSelf setLocationTxId:nil];
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
    [self next];
}

- (void)next {
    UIViewController* questionIntroVC = [HEMOnboardingStoryboard instantiateSleepQuestionIntroViewController];
    [[self navigationController] setViewControllers:@[questionIntroVC] animated:YES];
}

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

#pragma mark - Clean Up

- (void)dealloc {
    if ([self locationTxId] != nil) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
}

@end
