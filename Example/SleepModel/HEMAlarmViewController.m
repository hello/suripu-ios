
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSettings.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMColorUtils.h"

@interface HEMAlarmViewController () <UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer* panGestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel* alarmTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmChangeInstructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundNameLabel;
@property (strong, nonatomic) IBOutlet UISwitch* alarmEnabledSwitch;
@property (weak, nonatomic) IBOutlet UILabel* wakeUpInstructionsLabel;
@property (strong, nonatomic) CAGradientLayer* gradientLayer;

@property (nonatomic) CGFloat previousLocationY;
@end

@implementation HEMAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat fontSize = [SENSettings timeFormat] == SENTimeFormat12Hour ? 60.f : 90.f;
    self.alarmTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontSize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSMutableDictionary* dict = self.navigationController.navigationBar.titleTextAttributes.mutableCopy;
    dict[NSForegroundColorAttributeName] = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    [self updateViewWithAlarmSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    NSMutableDictionary* dict = self.navigationController.navigationBar.titleTextAttributes.mutableCopy;
    dict[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
}

- (void)configureViewBackground
{
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer new];
        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    NSInteger hour = [SENAlarm savedAlarm].hour;
    CGFloat intensity = 0;
    if (hour < 12) {
        intensity = hour / 11.0;
    } else {
        intensity = (23 - hour) / 12.0;
    }
    intensity += [SENAlarm savedAlarm].minute / 360.f;
    CGFloat y = (self.edgesForExtendedLayout & UIRectEdgeTop) ? -(CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])) : 0;
    CGRect frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [HEMColorUtils configureLayer:self.gradientLayer withBlueBackgroundGradientInFrame:frame intensityLevel:intensity];
}

- (void)updateViewWithAlarmSettings
{
    SENAlarm* savedAlarm = [SENAlarm savedAlarm];
    self.alarmEnabledSwitch.on = [savedAlarm isOn];
    self.alarmSoundNameLabel.text = savedAlarm.soundName;
    struct SENAlarmTime earliestAlarmTime = [savedAlarm timeByAddingMinutes:-30];
    NSString* earliestAlarmTimeText = [self textForHour:earliestAlarmTime.hour minute:earliestAlarmTime.minute];
    NSString* currentAlarmTimeText = [self textForHour:savedAlarm.hour minute:savedAlarm.minute];
    self.alarmTimeLabel.text = currentAlarmTimeText;

    NSString* rawText = [NSString stringWithFormat:NSLocalizedString(@"alarm.time-range.format", nil), earliestAlarmTimeText, currentAlarmTimeText];
    UIFont* emFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
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

#pragma mark - Actions

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    [SENAlarm savedAlarm].on = [sender isOn];
    [self updateViewWithAlarmSettings];
}

- (IBAction)panAlarmTime:(UIPanGestureRecognizer*)sender
{
    CGFloat currentLocationY = [sender locationInView:self.view].y;
    if (self.previousLocationY != 0) {
        CGFloat distanceMoved = -1 * (self.previousLocationY - currentLocationY);
        [[SENAlarm savedAlarm] incrementAlarmTimeByMinutes:distanceMoved];
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
    return indexPath.row == 1 && indexPath.section == 0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    self.previousLocationY = 0;
    return YES;
}

@end
