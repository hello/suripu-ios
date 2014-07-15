
#import <SenseKit/SENAlarm.h>
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

@property (nonatomic) CGFloat previousLocationY;
@end

@implementation HEMAlarmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewWithAlarmSettings];
}

- (void)configureViewBackground
{
    [self.view.layer insertSublayer:[HEMColorUtils layerWithBlueBackgroundGradientInFrame:self.view.bounds]
                            atIndex:0];
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
    UIFont* emFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
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
}

- (NSString*)textForHour:(NSInteger)hour minute:(NSInteger)minute
{
    NSString* minuteText = minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)minute] : [NSString stringWithFormat:@"%ld", (long)minute];
    return [NSString stringWithFormat:@"%ld:%@", (long)hour, minuteText];
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
