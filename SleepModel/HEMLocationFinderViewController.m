
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingService.h"
#import "HEMLocationCenter.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBaseController+Protected.h"
#import "HEMBluetoothUtils.h"

@interface HEMLocationFinderViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapHeightConstraint;

@property (nonatomic, copy) NSString* locationTxId;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventLocation]; 
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self mapHeightConstraint] withDiff:-90.0f];
}

- (void)viewDidEnterBackground {
    [super viewDidEnterBackground];
    DDLogVerbose(@"did enter background");
    if ([self locationTxId]) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
        [self setLocationTxId:nil];
        [[self locationButton] setEnabled:YES];
    }
}

#pragma mark - Actions

- (IBAction)requestLocation:(id)sender {
    [[self locationButton] setEnabled:NO];
    
    if ([self locationTxId]) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
    
    NSError* error = nil;
    __weak typeof(self) weakSelf = self;
    self.locationTxId =
        [[HEMLocationCenter sharedCenter] locate:&error success:^BOOL(double lat, double lon, double accuracy) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            SENAccount* account = [[HEMOnboardingService sharedService] currentAccount];
            [account setLatitude:@(lat)];
            [account setLongitude:@(lon)];
            
            [[strongSelf locationButton] setEnabled:YES];
            [strongSelf setLocationTxId:nil];
            [strongSelf uploadCollectedData:YES];
            [strongSelf trackPermission:NO error:nil];
            [strongSelf next];
            return NO;
        } failure:^BOOL(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[strongSelf locationButton] setEnabled:YES];
            [strongSelf showLocationError:error];
            [strongSelf setLocationTxId:nil];
            [strongSelf trackPermission:NO error:error];
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
            return NO;
        }];
    
    if (error != nil) {
        [[self locationButton] setEnabled:YES];
        [self showLocationError:error];
        [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
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
    [[HEMOnboardingService sharedService] updateCurrentAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            DDLogVerbose(@"update completed with error %@", error);
            if (retry) {
                DDLogVerbose(@"failed to update account with user information");
                [strongSelf uploadCollectedData:NO];
            }
        }
    }];
}

- (void)next {
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard locationToPushSegueIdentifier]
                              sender:self];
}

#pragma mark - Clean Up

- (void)dealloc {
    if (_locationTxId) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:_locationTxId];
    }
}

@end
