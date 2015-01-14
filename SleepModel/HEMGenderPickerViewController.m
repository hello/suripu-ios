#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "UIFont+HEMStyle.h"

#import "HEMGenderPickerViewController.h"
#import "HEMOnboardingCache.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"

@interface HEMGenderPickerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *selectorContainer;
@property (weak, nonatomic) IBOutlet UIView *selectorDivider;
@property (weak, nonatomic) IBOutlet UIButton *femaleSelectorButton;
@property (weak, nonatomic) IBOutlet UIButton *maleSelectorButton;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectorTopConstraint;

@property (strong, nonatomic) UIColor* selectedColor;
@property (strong, nonatomic) UIColor* selectedBorderColor;
@property (assign, nonatomic) SENAccountGender selectedGender;

@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setSelectedColor:[[HelloStyleKit senseBlueColor] colorWithAlphaComponent:0.05f]];
    [self setSelectedBorderColor:[[HelloStyleKit senseBlueColor] colorWithAlphaComponent:0.4f]];
    
    [[[self skipButton] titleLabel] setFont:[UIFont secondaryButtonFont]];
    [[self descriptionLabel] setAttributedText:[HEMOnboardingUtils demographicReason]];
    [self configureGenderSelectors];
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        NSString* cancel = NSLocalizedString(@"actions.cancel", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
        [[self skipButton] setTitle:cancel forState:UIControlStateNormal];
    } else {
        [self enableBackButton:NO];
        [SENAnalytics track:kHEMAnalyticsEventOnBGender];
    }
}

- (void)adjustConstraintsForIPhone4 {
    [super adjustConstraintsForIPhone4];
    [self updateConstraint:[self selectorTopConstraint] withDiff:40];
}

- (void)configureGenderSelectors {
    [[self selectorDivider] setBackgroundColor:[HelloStyleKit separatorColor]];
    [[[self selectorContainer] layer] setBorderWidth:1.0f];
    [[[self selectorContainer] layer] setBorderColor:[[HelloStyleKit separatorColor] CGColor]];
    
    [[[self femaleSelectorButton] layer] setBorderWidth:0.0f];
    [[[self femaleSelectorButton] layer] setBorderColor:[[self selectedBorderColor] CGColor]];
    [[[self femaleSelectorButton] titleLabel] setFont:[UIFont genderButtonTitleFont]];
    [[[self maleSelectorButton] layer] setBorderWidth:0.0f];
    [[[self maleSelectorButton] layer] setBorderColor:[[self selectedBorderColor] CGColor]];
    [[[self maleSelectorButton] titleLabel] setFont:[UIFont genderButtonTitleFont]];
    
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
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self centerButtonContent:[self femaleSelectorButton]];
    [self centerButtonContent:[self maleSelectorButton]];
}

- (void)centerButtonContent:(UIButton*)button {
    CGSize imageSize = [[button imageView] frame].size;
    CGSize titleSize = [[button titleLabel] frame].size;
    
    CGFloat spacing = 20.0f;
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    [button setImageEdgeInsets:UIEdgeInsetsMake(-(totalHeight-imageSize.height), 0.0, 0.0, -titleSize.width)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -imageSize.width, -(totalHeight-titleSize.height),0.0)];
}

- (void)button:(UIButton*)button isSelected:(BOOL)selected {
    [button setSelected:selected];
    
    if (selected) {
        [button setBackgroundColor:[self selectedColor]];
        [[button layer] setBorderWidth:1.0f];
    } else {
        [button setBackgroundColor:[UIColor clearColor]];
        [[button layer] setBorderWidth:0.0f];
    }
    
}

- (IBAction)setGenderAsFemale:(id)sender {
    [self button:[self femaleSelectorButton] isSelected:YES];
    [self button:[self maleSelectorButton] isSelected:NO];
    [self setSelectedGender:SENAccountGenderFemale];
}

- (IBAction)setGenderAsMale:(id)sender {
    [self button:[self femaleSelectorButton] isSelected:NO];
    [self button:[self maleSelectorButton] isSelected:YES];
    [self setSelectedGender:SENAccountGenderMale];
}

- (void)setGenderAsOther {
    [self button:[self femaleSelectorButton] isSelected:NO];
    [self button:[self maleSelectorButton] isSelected:NO];
    [self setSelectedGender:SENAccountGenderOther];
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
