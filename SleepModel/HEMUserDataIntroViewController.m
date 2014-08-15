
#import "HEMUserDataIntroViewController.h"

@interface HEMUserDataIntroViewController ()

@end

@implementation HEMUserDataIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)skipUserDataCollection:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
