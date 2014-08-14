
#import "HEMLocationFinderViewController.h"

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
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)skipRequestingLocation:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}
@end
