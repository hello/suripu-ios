
#import "HEMLocationFinderViewController.h"
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
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)skipRequestingLocation:(id)sender
{
    [self uploadCollectedData];
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
