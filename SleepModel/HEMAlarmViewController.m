
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENSettings.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMAlarmCache.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"
#import "HEMAlarmUtils.h"
#import "UIFont+HEMStyle.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmViewController () <UITableViewDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer* panGestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel* alarmTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmChangeInstructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmRepeatLabel;
@property (strong, nonatomic) IBOutlet UISwitch* alarmSmartSwitch;
@property (weak, nonatomic) IBOutlet UILabel* wakeUpInstructionsLabel;
@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (strong, nonatomic) NSDictionary* markdownAttributes;

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;
@end

@implementation HEMAlarmViewController

static CGFloat const HEMAlarmPanningSpeedMultiplier = 0.5f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.alarmTimeLabel.font = [UIFont largeNumberFont];
    self.alarmCache = [HEMAlarmCache new];
    self.originalAlarmCache = [HEMAlarmCache new];
    if (self.alarm) {
        [self.alarmCache cacheValuesFromAlarm:self.alarm];
        [self.originalAlarmCache cacheValuesFromAlarm:self.alarm];
        self.unsavedAlarm = ![self.alarm isSaved];
    }
    self.markdownAttributes = @{
        @(EMPH) : @{
            NSFontAttributeName : [UIFont alarmMessageBoldFont],
        },
        @(PARA) : @{
            NSForegroundColorAttributeName : [UIColor whiteColor],
        },
        @(PLAIN) : @{
            NSFontAttributeName : [UIFont alarmMessageFont]
        }
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNavigationBar];
    [self updateViewWithAlarmSettings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTintColor:[HelloStyleKit backViewNavTitleColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [HelloStyleKit backViewNavTitleColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:[HEMMainStoryboard pickSoundSegueSegueIdentifier]]) {
        HEMAlarmSoundTableViewController* controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
    }
    else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        HEMAlarmRepeatTableViewController* controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
        controller.alarm = self.alarm;
    }
}

- (void)configureViewBackground
{
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer new];
        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    CGFloat y = (self.edgesForExtendedLayout & UIRectEdgeTop) ? -(CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame])) : 0;
    self.gradientLayer.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [HEMColorUtils configureLayer:self.gradientLayer forHourOfDay:self.alarmCache.hour];
}

- (void)updateNavigationBar
{
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSFontAttributeName: [UIFont navButtonTitleFont]};
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont settingsTitleFont]
    }];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)updateViewWithAlarmSettings
{
    self.alarmSmartSwitch.on = [self.alarmCache isSmart];
    self.alarmSoundNameLabel.text = self.alarmCache.soundName;
    struct SENAlarmTime alarmTime = [self timeFromCachedValues];
    struct SENAlarmTime earliestAlarmTime = [SENAlarm time:alarmTime byAddingMinutes:-30];
    NSString* earliestAlarmTimeText = [self textForHour:earliestAlarmTime.hour minute:earliestAlarmTime.minute];
    NSString* currentAlarmTimeText = [self textForHour:alarmTime.hour minute:alarmTime.minute];
    self.alarmTimeLabel.text = currentAlarmTimeText;
    self.alarmRepeatLabel.text = [HEMAlarmUtils repeatTextForUnitFlags:self.alarmCache.repeatFlags];

    NSString* rawText = [NSString stringWithFormat:NSLocalizedString(@"alarm.time-range.format", nil), earliestAlarmTimeText, currentAlarmTimeText];
    self.wakeUpInstructionsLabel.attributedText = markdown_to_attr_string(rawText, 0, self.markdownAttributes);
    self.alarmChangeInstructionsLabel.attributedText = markdown_to_attr_string(NSLocalizedString(@"alarm.update.instructions", nil), 0, self.markdownAttributes);
    [self configureViewBackground];
}

- (struct SENAlarmTime)timeFromCachedValues
{
    return (struct SENAlarmTime){
        .hour = self.alarmCache.hour,
        .minute = self.alarmCache.minute
    };
}

- (NSString*)textForHour:(NSInteger)hour minute:(NSInteger)minute
{
    struct SENAlarmTime time;
    time.hour = hour;
    time.minute = minute;
    return [SENAlarm localizedValueForTime:time];
}

#pragma mark - Actions

- (IBAction)dismissFromView:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveAndDismissFromView:(id)sender
{
    [self updateAlarmFromCache:self.alarmCache];
    __weak typeof(self) weakSelf = self;
    [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success)
            [strongSelf dismissFromView:nil];
        else if ([self isUnsavedAlarm])
            [strongSelf.alarm delete];
        else
            [strongSelf updateAlarmFromCache:strongSelf.originalAlarmCache];
    }];
}

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    self.alarmCache.smart = [sender isOn];
    [self updateViewWithAlarmSettings];
}

- (IBAction)panAlarmTime:(UIPanGestureRecognizer*)sender
{
    CGFloat distanceMoved = [sender translationInView:self.view].y;
    CGFloat minutes = distanceMoved * HEMAlarmPanningSpeedMultiplier;
    struct SENAlarmTime alarmTime = [self timeFromCachedValues];
    alarmTime = [SENAlarm time:alarmTime byAddingMinutes:minutes];
    self.alarmCache.hour = alarmTime.hour;
    self.alarmCache.minute = alarmTime.minute;
    [self updateViewWithAlarmSettings];
    [sender setTranslation:CGPointZero inView:self.view];
}

- (IBAction)showAlarmTimeExplanationDialog:(UIButton*)sender
{
    [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"alarm.time-explanation.title", nil)
                                          message:NSLocalizedString(@"alarm.time-explanation.message", nil)
                             presentingController:self];
}

- (void)updateAlarmFromCache:(HEMAlarmCache*)cache
{
    self.alarm.smartAlarm = [cache isSmart];
    self.alarm.minute = cache.minute;
    self.alarm.hour = cache.hour;
    self.alarm.repeatFlags = cache.repeatFlags;
    self.alarm.soundName = cache.soundName;
    [self.alarm save];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == 0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    [gestureRecognizer setTranslation:CGPointZero inView:self.view];
    return YES;
}

@end
