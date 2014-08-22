#import <QuartzCore/QuartzCore.h>
#import "HEMUserDataIntroViewController.h"
#import "UIView+HEMMotionEffects.h"
#import "HEMBaseController+Protected.h"

@interface HEMUserDataIntroViewController ()

@property (nonatomic, strong) UIColor* originalNavTintColor;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonBotSpaceConstraint;

@end

@implementation HEMUserDataIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setOriginalNavTintColor:[[[self navigationController] navigationBar] tintColor]];
    [[self bgImageView] add3DEffectWithBorder:10.0f];
}

- (void)adjustConstraintsForIPhone4 {
    [self updateConstraint:[self goButtonBotSpaceConstraint] withDiff:-40];
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
