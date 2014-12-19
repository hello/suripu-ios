
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENSettings.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMAlarmCache.h"
#import "HelloStyleKit.h"
#import "HEMAlarmUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmViewController () <UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel* alarmEnabledLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmSoundNameLabel;
@property (weak, nonatomic) IBOutlet UILabel* alarmRepeatLabel;
@property (strong, nonatomic) IBOutlet UISwitch* alarmSmartSwitch;
@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (strong, nonatomic) NSDictionary* markdownAttributes;

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;
@end

@implementation HEMAlarmViewController

static CGFloat const HEMAlarmPanningSpeedMultiplier = 0.25f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.alarmCache = [HEMAlarmCache new];
    self.originalAlarmCache = [HEMAlarmCache new];
    self.use12Hour = [SENSettings timeFormat] == SENTimeFormat12Hour;
    if (self.alarm) {
        [self.alarmCache cacheValuesFromAlarm:self.alarm];
        [self.originalAlarmCache cacheValuesFromAlarm:self.alarm];
        self.unsavedAlarm = ![self.alarm isSaved];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewWithAlarmSettings];
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

- (void)updateViewWithAlarmSettings
{
    self.alarmSmartSwitch.on = [self.alarmCache isSmart];
    self.alarmSoundNameLabel.text = self.alarmCache.soundName;
    self.alarmRepeatLabel.text = [HEMAlarmUtils repeatTextForUnitFlags:self.alarmCache.repeatFlags];
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

- (void)dismiss:(BOOL)saved {
    if (self.delegate) {
        if (saved) {
            [self.delegate didSaveAlarm:self.alarm from:self];
        } else {
            [self.delegate didCancelAlarmFrom:self];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
}

- (IBAction)dismissFromView:(id)sender
{
    [self dismiss:NO];
}

- (IBAction)saveAndDismissFromView:(id)sender
{
    [self updateAlarmFromCache:self.alarmCache];
    __weak typeof(self) weakSelf = self;
    [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success)
            [strongSelf dismiss:YES];
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
    CGFloat distance = [sender translationInView:self.view].y * HEMAlarmPanningSpeedMultiplier;
    if (distance < 0.75 && distance > -0.75)
        return;
    CGFloat minutes = distance < 0 ? floorf(distance) : ceilf(distance);
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
    return indexPath.row != 0;
}

#pragma mark - UIPickerView

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadComponent:component];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return component == 1 ? 15.f : 100.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 80.f;
}

#pragma mark UIPickerViewDatasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self shouldUse12Hour] ? 4 : 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0: return [self shouldUse12Hour] ? 12 : 24;
        case 1: return 1;
        case 2: return 12;
        case 3: return 2;
        default: return 0;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString* text = [self textForRow:row forComponent:component];
    UILabel* label = (id)view ?: [UILabel new];
    label.text = text;
    label.textAlignment = [self textAlignmentForComponent:component];
    label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size: component == 3 ? 20.f : 72.f];
    [UIView animateWithDuration:0.2f animations:^{
        BOOL isSelectedRow = [pickerView selectedRowInComponent:component] == row;
        CGAffineTransform transform = isSelectedRow ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.5f, 0.5f);
        if (!CGAffineTransformEqualToTransform(label.transform, transform))
            label.transform = transform;
        label.textColor = isSelectedRow ? [HelloStyleKit lightSleepColor] : [UIColor grayColor];
    }];
    return label;
}

- (NSString *)textForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0: {
            NSInteger hour = [self shouldUse12Hour] ? row + 1 : row;
            return [NSString stringWithFormat:@"%ld", hour];
        }
        case 1: return @":";
        case 2: {
            NSInteger minute = row * 5;
            NSString* format = minute < 10 ? @"0%ld" : @"%ld";
            return [NSString stringWithFormat:format, minute];
        }
        case 3: {
            NSString* format = row == 0 ? @"alarms.alarm.meridiem.am" : @"alarms.alarm.meridiem.pm";
            return [NSLocalizedString(format, nil) uppercaseString];
        }
        default: return nil;
    }
}

- (NSTextAlignment)textAlignmentForComponent:(NSInteger)component
{
    switch (component) {
        case 0: return NSTextAlignmentRight;
        case 1: return NSTextAlignmentCenter;
        case 2: return NSTextAlignmentCenter;
        case 3:
        default: return NSTextAlignmentLeft;
    }
}

@end
