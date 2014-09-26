
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSettings.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"
#import "HEMAlarmTextUtils.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsTheme.h"

@interface HEMAlarmViewController () <UITableViewDelegate, UIGestureRecognizerDelegate, HEMSettingsTheme>
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer* panGestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel* alarmTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmChangeInstructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmRepeatLabel;
@property (strong, nonatomic) IBOutlet UISwitch* alarmEnabledSwitch;
@property (weak, nonatomic) IBOutlet UILabel* wakeUpInstructionsLabel;
@property (strong, nonatomic) CAGradientLayer* gradientLayer;

@property (nonatomic) CGFloat previousLocationY;
@end

@implementation HEMAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    CGFloat fontSize = [SENSettings timeFormat] == SENTimeFormat12Hour ? 60.f : 90.f;
    self.alarmTimeLabel.font = [UIFont fontWithName:@"Agile-Thin" size:fontSize];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[HelloStyleKit chevronIconLeft] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self updateViewWithAlarmSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:[HEMMainStoryboard pickSoundSegueSegueIdentifier]]) {
        HEMAlarmSoundTableViewController* controller = segue.destinationViewController;
        controller.alarm = self.alarm;
    } else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        HEMAlarmRepeatTableViewController* controller = segue.destinationViewController;
        controller.alarm = self.alarm;
    }
}

- (void)configureViewBackground
{
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer new];
        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    NSInteger hour = self.alarm.hour;
    CGFloat y = (self.edgesForExtendedLayout & UIRectEdgeTop) ? -(CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])) : 0;
    self.gradientLayer.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [HEMColorUtils configureLayer:self.gradientLayer forHourOfDay:hour];
}

- (void)updateViewWithAlarmSettings
{
    self.alarmEnabledSwitch.on = [self.alarm isSmartAlarm];
    self.alarmSoundNameLabel.text = self.alarm.soundName;
    struct SENAlarmTime earliestAlarmTime = [self.alarm timeByAddingMinutes:-30];
    NSString* earliestAlarmTimeText = [self textForHour:earliestAlarmTime.hour minute:earliestAlarmTime.minute];
    NSString* currentAlarmTimeText = [self textForHour:self.alarm.hour minute:self.alarm.minute];
    self.alarmTimeLabel.text = currentAlarmTimeText;
    self.alarmRepeatLabel.text = [HEMAlarmTextUtils repeatTextForAlarm:self.alarm];

    NSString* rawText = [NSString stringWithFormat:NSLocalizedString(@"alarm.time-range.format", nil), earliestAlarmTimeText, currentAlarmTimeText];
    UIFont* emFont = [UIFont fontWithName:@"Agile-Medium" size:14.0];
    NSDictionary* attributes = @{
        @(EMPH) : @{
            NSFontAttributeName : emFont,
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor whiteColor],
        }
    };

    self.wakeUpInstructionsLabel.attributedText = markdown_to_attr_string(rawText, 0, attributes);
    self.alarmChangeInstructionsLabel.attributedText = markdown_to_attr_string(NSLocalizedString(@"alarm.update.instructions", nil), 0, attributes);
    [self configureViewBackground];
}

- (NSString*)textForHour:(NSInteger)hour minute:(NSInteger)minute
{
    struct SENAlarmTime time;
    time.hour = hour;
    time.minute = minute;
    return [SENAlarm localizedValueForTime:time];
}

#pragma mark - HEMSettingsTheme

- (BOOL)useGradientBackground
{
    return NO;
}

#pragma mark - Actions

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    self.alarm.smartAlarm = [sender isOn];
    [self updateViewWithAlarmSettings];
}

- (IBAction)panAlarmTime:(UIPanGestureRecognizer*)sender
{
    CGFloat currentLocationY = [sender locationInView:self.view].y;
    if (self.previousLocationY != 0) {
        CGFloat distanceMoved = -1 * (self.previousLocationY - currentLocationY);
        [self.alarm incrementAlarmTimeByMinutes:distanceMoved];
        [self updateViewWithAlarmSettings];
        self.previousLocationY = 0;
    }
    self.previousLocationY = currentLocationY;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return (indexPath.row == 1 || indexPath.row == 2) && indexPath.section == 0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    self.previousLocationY = 0;
    return YES;
}

@end
