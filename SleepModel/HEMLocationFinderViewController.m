
#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"
#import "HEMLocationCenter.h"

@interface HEMLocationFinderViewController ()

@property (nonatomic, copy) NSString* locationTxId;

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)finish {
    [self uploadCollectedData];
    [self dismissDataCollectionFlow];
}

- (IBAction)requestLocation:(id)sender {
    NSError* error = nil;
    __weak typeof(self) weakSelf = self;
    self.locationTxId =
        [[HEMLocationCenter sharedCenter] locate:&error success:^(double lat, double lon, double accuracy) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                NSLog(@"got lat %f, long %f, accuracy %f", lat, lon, accuracy);
                [[HEMLocationCenter sharedCenter] stopLocatingFor:[strongSelf locationTxId]];
                [strongSelf setLocationTxId:nil];
            }
        } failure:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[HEMLocationCenter sharedCenter] stopLocatingFor:[strongSelf locationTxId]];
                [strongSelf setLocationTxId:nil];
            }
        }];
    if (error != nil) {
        // TODO (jimmy): show error
    }
}

- (IBAction)skipRequestingLocation:(id)sender
{
    [self uploadCollectedData];
    [self dismissDataCollectionFlow];
}

- (void)dismissDataCollectionFlow
{
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[HEMSettingsTableViewController class]]) {
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)uploadCollectedData
{
    [HEMUserDataCache updateAccountWithSharedUserDataWithCompletion:^(NSError* error) {
        if (error) {
            NSLog(@"OH NOES: %@", error);
        }
    }];
}

- (void)dealloc {
    if ([self locationTxId] != nil) {
        [[HEMLocationCenter sharedCenter] stopLocatingFor:[self locationTxId]];
    }
}

@end
