
#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"
#import "HEMLocationCenter.h"
#import "HEMActionButton.h"

@interface HEMLocationFinderViewController ()

@property (nonatomic, copy) NSString* locationTxId;
@property (weak, nonatomic) IBOutlet HEMActionButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)finish {
    [self uploadCollectedData];
    [self next];
}

- (void)showActivity {
    [[self skipButton] setEnabled:NO];
    [[self locationButton] showActivity];
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
                [strongSelf stopActivity];
                NSLog(@"got lat %f, long %f, accuracy %f", lat, lon, accuracy);
                // TODO (jimmy): where to put this data?
                [strongSelf setLocationTxId:nil];
                [strongSelf finish];
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

- (IBAction)skipRequestingLocation:(id)sender
{
    [self uploadCollectedData];
    [self next];
}

- (void)next {
    [self performSegueWithIdentifier:@"next" sender:self];
}

- (void)uploadCollectedData
{
    [HEMUserDataCache updateAccountWithSharedUserDataWithCompletion:^(NSError* error) {
        if (error) {
            NSLog(@"OH NOES: %@", error);
        }
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
    NSString* errorMessage = [self errorMessageForLocationError:error];
    NSString* title = NSLocalizedString(@"location.error.title", nil);
    [[[UIAlertView alloc] initWithTitle:title
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

#pragma mark - Clean Up

- (void)dealloc {
    if ([self locationTxId] != nil) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
}

@end
