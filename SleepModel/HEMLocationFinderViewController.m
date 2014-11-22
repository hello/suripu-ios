
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"
#import "HEMLocationCenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"
#import "HEMBluetoothUtils.h"

@interface HEMLocationFinderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (nonatomic, copy) NSString* locationTxId;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locateButtonWidthConstraint;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[super navigationItem] setHidesBackButton:YES];
    
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [[self subtitleLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
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
                [strongSelf trackPermission:NO error:nil];
                [strongSelf next];
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
    [self trackPermission:YES error:nil];
    [self next];
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
                     if (error)
                         DDLogVerbose(@"update completed with error %@", error);
                     __strong typeof(weakSelf) strongSelf = weakSelf;
                     if (!strongSelf) return;
                     if (error != nil && retry) {
                         DDLogVerbose(@"failed to update account with user information");
                         [strongSelf uploadCollectedData:NO];
                     } // TODO (jimmy): else if error, no retry, what should we do?
                 }];
}

- (void)next {
    if (![HEMBluetoothUtils stateAvailable]) {
        [self performSelector:@selector(next)
                   withObject:nil
                   afterDelay:0.1f];
        return;
    }
    
    NSString* segueId
        = ![HEMBluetoothUtils isBluetoothOn]
        ? [HEMOnboardingStoryboard senseSetupNoBleSegueIdentifier]
        : [HEMOnboardingStoryboard senseSetupSegueIdentifier];

    [HEMOnboardingUtils saveOnboardingCheckpoint:HEMOnboardingCheckpointAccountDone];
    [self performSegueWithIdentifier:segueId sender:self];
}

#pragma mark - Clean Up

- (void)dealloc {
    if ([self locationTxId] != nil) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
}

@end
