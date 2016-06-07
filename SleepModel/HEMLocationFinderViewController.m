
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMOnboardingService.h"
#import "HEMLocationService.h"
#import "HEMActionButton.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMBluetoothUtils.h"
#import "HEMActivityCoverView.h"

@interface HEMLocationFinderViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (strong, nonatomic) HEMLocationActivity* locationActivity;
@property (strong, nonatomic) HEMLocationService* locationService;
@property (strong, nonatomic) HEMActivityCoverView* activityView;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [self enableBackButton:NO];
    [self trackAnalyticsEvent:HEMAnalyticsEventLocation];
}

- (void)startLocationActivity {
    NSError* startError = nil;
    __weak typeof(self) weakSelf = self;
    self.locationActivity = [[self locationService] startLocationActivity:^(HEMLocation * mostRecentLocation, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        if (mostRecentLocation) {
            SENAccount* account = [[HEMOnboardingService sharedService] currentAccount];
            [account setLatitude:@([mostRecentLocation lat])];
            [account setLongitude:@([mostRecentLocation lon])];
            [strongSelf uploadCollectedData:YES];
            [strongSelf trackPermission:NO error:nil];
            [strongSelf next];
        } else if (error) {
            NSString* title = NSLocalizedString(@"location.error.title", nil);
            NSString* message = [strongSelf errorMessageForLocationError:error];
            [strongSelf showMessageDialog:message title:title];
            [strongSelf trackPermission:NO error:error];
        }
        
        [strongSelf stopLocationActivity:error == nil];
        
    } error:&startError];
    
    if (startError) {
        NSString* message = [self errorMessageForLocationError:startError];
        NSString* title = NSLocalizedString(@"location.error.title", nil);
        [self showMessageDialog:message title:title];
    } else if ([self locationActivity]) {
        UIView* parentView = [[self navigationController] view];
        NSString* message = NSLocalizedString(@"location.activity.status", nil);
        [self setActivityView:[HEMActivityCoverView new]];
        [[self activityView] showInView:parentView withText:message activity:YES completion:nil];
    }
}

- (void)stopLocationActivity:(BOOL)success {
    [[self locationService] stopLocationActivity:[self locationActivity]];
    [self setLocationActivity:nil];
    
    NSString* message = success ? NSLocalizedString(@"status.success", nil) : nil;
    [[self activityView] dismissWithResultText:message
                               showSuccessMark:success
                                        remove:YES
                                    completion:nil];
    
}

#pragma mark - Actions

- (IBAction)requestLocation:(id)sender {
    if ([self locationActivity]) {
        return;
    }
    
    if (![self locationService]) {
        [self setLocationService:[HEMLocationService new]];
    }
    
    [self startLocationActivity];
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
    } else if ([error code] == HEMLocationErrorCodeDenied) {
        status = kHEManaltyicsEventStatusDenied;
    } else if ([error code] == HEMLocationErrorCodeNotEnabled) {
        status = kHEManaltyicsEventStatusDisabled;
    }
    
    NSDictionary* properties = status != nil ? @{kHEManaltyicsEventPropStatus : status} : nil;
    [SENAnalytics track:kHEMAnalyticsEventPermissionLoc properties:properties];
}

#pragma mark - Alerts

- (NSString*)errorMessageForLocationError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMLocationErrorDomain]) {
        switch ([error code]) {
            case HEMLocationErrorCodeDenied:
                return NSLocalizedString(@"location.error.denied", nil);
            case HEMLocationErrorCodeNotEnabled:
                return NSLocalizedString(@"location.error.not-enabled", nil);
            default:
                return nil;
        }
    } else {
        return NSLocalizedString(@"location.error.weak-signal", nil);
    }
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
    if (_locationActivity && _locationService) {
        [_locationService stopLocationActivity:_locationActivity];
    }
}

@end
