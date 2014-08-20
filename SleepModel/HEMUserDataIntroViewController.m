
#import "HEMUserDataIntroViewController.h"

@interface HEMUserDataIntroViewController ()

@property (nonatomic, strong) UIColor* originalNavTintColor;

@end

@implementation HEMUserDataIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setOriginalNavTintColor:[[[self navigationController] navigationBar] tintColor]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[[self navigationController] navigationBar] setTintColor:[UIColor whiteColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[self navigationController] navigationBar] setTintColor:[self originalNavTintColor]];
}

- (IBAction)skipUserDataCollection:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

@end
