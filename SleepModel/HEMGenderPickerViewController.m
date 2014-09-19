#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAccount.h>

#import "HEMGenderPickerViewController.h"
#import "HEMUserDataCache.h"
#import "HEMBaseController+Protected.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMActionButton.h"

@interface HEMGenderPickerViewController ()

@property (weak, nonatomic) IBOutlet UIButton* femaleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* femaleTitleButton;
@property (weak, nonatomic) IBOutlet UIButton* maleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* maleTitleButton;
@property (weak, nonatomic) IBOutlet UIButton* otherTitleButton;
@property (weak, nonatomic) IBOutlet UIView* lineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fIconButtonBotConstraint;
@property (weak, nonatomic) IBOutlet HEMActionButton *doneButton;

@property (assign, nonatomic) SENAccountGender selectedGender;
@property (assign, nonatomic) BOOL loadedDefault;

@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self delegate] != nil) {
        NSString* title = NSLocalizedString(@"status.success", nil);
        [[self doneButton] setTitle:title forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self loadedDefault]) {
        switch ([self defaultGender]) {
            case SENAccountGenderMale:
                [self setGenderAsMale:nil];
                break;
            case SENAccountGenderFemale:
                [self setGenderAsFemale:nil];
                break;
            default:
                [self setGenderAsOther:nil];
                break;
        }
    }
}

- (void)adjustConstraintsForIPhone4 {
    CGFloat diff = -40.0f;
    [self updateConstraint:[self fIconButtonBotConstraint] withDiff:diff];
}

- (IBAction)setGenderAsFemale:(id)sender
{
    [self setSelectedGender:SENAccountGenderFemale];
    [self selectButton:self.femaleTitleButton];
    [UIView animateWithDuration:0.5f animations:^{
        self.femaleTitleButton.alpha = 1.f;
        self.femaleIconButton.alpha = 1.f;
        self.maleIconButton.alpha = 0.5f;
        self.maleTitleButton.alpha = 0.5f;
        self.otherTitleButton.alpha = 0.5f;
    }];
}

- (IBAction)setGenderAsOther:(id)sender
{
    [self setSelectedGender:SENAccountGenderOther];
    [self selectButton:self.otherTitleButton];
    [UIView animateWithDuration:0.5f animations:^{
        self.femaleTitleButton.alpha = 0.5f;
        self.femaleIconButton.alpha = 0.5f;
        self.maleIconButton.alpha = 0.5f;
        self.maleTitleButton.alpha = 0.5f;
        self.otherTitleButton.alpha = 1.f;
    }];
}

- (IBAction)setGenderAsMale:(id)sender
{
    [self setSelectedGender:SENAccountGenderMale];
    [self selectButton:self.maleTitleButton];
    [UIView animateWithDuration:0.5f animations:^{
        self.femaleTitleButton.alpha = 0.5f;
        self.femaleIconButton.alpha = 0.5f;
        self.maleIconButton.alpha = 1.f;
        self.maleTitleButton.alpha = 1.f;
        self.otherTitleButton.alpha = 0.5;
    }];
}

- (void)selectButton:(UIButton*)button
{
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = CGRectMake(CGRectGetMinX(button.frame), CGRectGetMaxY(button.frame) + 3.f, CGRectGetWidth(button.frame), 1.f);
        self.lineView.frame = frame;
    }];
}

- (IBAction)done:(id)sender {
    if ([self delegate] != nil) {
        [[self delegate] didSelectGender:[self selectedGender] from:self];
    } else {
        [[[HEMUserDataCache sharedUserDataCache] account] setGender:[self selectedGender]];
        [self performSegueWithIdentifier:[HEMOnboardingStoryboard heightSegueIdentifier]
                                  sender:self];
    }
}

@end
