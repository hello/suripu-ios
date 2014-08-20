#import <QuartzCore/QuartzCore.h>
#import "HEMUserDataIntroViewController.h"
#import "UIView+HEMMotionEffects.h"

@interface HEMUserDataIntroViewController ()

@property (nonatomic, strong) UIColor* originalNavTintColor;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@end

@implementation HEMUserDataIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setOriginalNavTintColor:[[[self navigationController] navigationBar] tintColor]];
    [[self bgImageView] add3DEffectWithBorder:10.0f];
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
