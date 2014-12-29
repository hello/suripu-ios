#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMGenderPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"

static CGFloat const kHEMGenderPickerDeselectedAlpha = 0.5f;
static CGFloat const kHEMGenderPickerSelectedAlpha = 1.0f;

@interface HEMGenderPickerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton* femaleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* femaleTitleButton;
@property (weak, nonatomic) IBOutlet UIButton* maleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* maleTitleButton;
@property (weak, nonatomic) IBOutlet UIView* lineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fIconButtonBotConstraint;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (assign, nonatomic) SENAccountGender selectedGender;

@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self navigationItem] setHidesBackButton:YES];
    [[self titleLabel] setFont:[UIFont onboardingTitleFont]];
    [[self subtitleLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
    
    switch ([self defaultGender]) {
        case SENAccountGenderMale:
            [self setGenderAsMale:nil];
            break;
        case SENAccountGenderFemale:
            [self setGenderAsFemale:nil];
            break;
        default:
            [self setGenderAsOther];
            break;
    }
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [SENAnalytics track:kHEMAnalyticsEventOnBGender];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    switch ([self selectedGender]) {
        case SENAccountGenderFemale:
            [self moveLineUnderButton:[self femaleTitleButton]];
            break;
        default:
            [self moveLineUnderButton:[self maleTitleButton]];
            break;
    }
}

- (void)moveLineUnderButton:(UIButton*)button {
    CGRect frame = CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame) + 3.f, CGRectGetWidth(button.frame), 1.f);
    self.lineView.frame = frame;
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self fIconButtonBotConstraint] withDiff:diff];
}

- (IBAction)setGenderAsFemale:(id)sender {
    [[self lineView] setHidden:NO];
    [self setSelectedGender:SENAccountGenderFemale];
    [self selectButton:self.femaleTitleButton];
    [UIView animateWithDuration:0.5f animations:^{
        self.femaleTitleButton.alpha = kHEMGenderPickerSelectedAlpha;
        self.femaleIconButton.alpha = kHEMGenderPickerSelectedAlpha;
        self.maleIconButton.alpha = kHEMGenderPickerDeselectedAlpha;
        self.maleTitleButton.alpha = kHEMGenderPickerDeselectedAlpha;
    }];
}

- (IBAction)setGenderAsMale:(id)sender {
    [[self lineView] setHidden:NO];
    [self setSelectedGender:SENAccountGenderMale];
    [self selectButton:self.maleTitleButton];
    [UIView animateWithDuration:0.5f animations:^{
        self.femaleTitleButton.alpha = kHEMGenderPickerDeselectedAlpha;
        self.femaleIconButton.alpha = kHEMGenderPickerDeselectedAlpha;
        self.maleIconButton.alpha = kHEMGenderPickerSelectedAlpha;
        self.maleTitleButton.alpha = kHEMGenderPickerSelectedAlpha;
    }];
}

- (void)setGenderAsOther {
    [self setSelectedGender:SENAccountGenderOther];
    [[self lineView] setHidden:YES];
    [[self femaleIconButton] setAlpha:kHEMGenderPickerDeselectedAlpha];
    [[self femaleTitleButton] setAlpha:kHEMGenderPickerDeselectedAlpha];
    [[self maleIconButton] setAlpha:kHEMGenderPickerDeselectedAlpha];
    [[self maleTitleButton] setAlpha:kHEMGenderPickerDeselectedAlpha];
    [self moveLineUnderButton:[self maleTitleButton]]; // just move it somewhere
}

- (void)selectButton:(UIButton*)button {
    [UIView animateWithDuration:0.25f animations:^{
        [self moveLineUnderButton:button];
    }];
}

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectGender:[self selectedGender] from:self];
    } else {
        [[[HEMOnboardingCache sharedCache] account] setGender:[self selectedGender]];
        [self next];
    }
}

- (IBAction)skip:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didCancelGenderFrom:self];
    } else {
        [self next];
    }
}

- (void)next {
    // update analytics property for gender
    [HEMAnalytics updateGender:[self selectedGender]];
    [self performSegueWithIdentifier:[HEMOnboardingStoryboard heightSegueIdentifier]
                              sender:self];
}

@end
