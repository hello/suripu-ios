#import <SenseKit/SENAPIAccount.h>

#import "HEMGenderPickerViewController.h"
#import "HEMUserDataCache.h"

@interface HEMGenderPickerViewController ()

@property (weak, nonatomic) IBOutlet UIButton* femaleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* femaleTitleButton;
@property (weak, nonatomic) IBOutlet UIButton* maleIconButton;
@property (weak, nonatomic) IBOutlet UIButton* maleTitleButton;
@property (weak, nonatomic) IBOutlet UIButton* otherTitleButton;
@property (weak, nonatomic) IBOutlet UIView* lineView;

@property (nonatomic) SENAPIAccountGender gender;
@end

@implementation HEMGenderPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setGenderAsOther:self.otherTitleButton];
}

- (IBAction)setGenderAsFemale:(id)sender
{
    self.gender = SENAPIAccountGenderFemale;
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
    self.gender = SENAPIAccountGenderOther;
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
    self.gender = SENAPIAccountGenderMale;
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

- (void)setGender:(SENAPIAccountGender)gender
{
    [[HEMUserDataCache sharedUserDataCache] setGender:gender];
    _gender = gender;
}

@end
