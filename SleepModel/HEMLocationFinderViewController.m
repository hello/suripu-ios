
#import "HEMLocationFinderViewController.h"
#import "HEMSettingsTableViewController.h"
#import "HEMUserDataCache.h"

@interface HEMLocationFinderViewController ()

@end

@implementation HEMLocationFinderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)requestLocation:(id)sender
{
    [self uploadCollectedData];
    [self dismissDataCollectionFlow];
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
@end
