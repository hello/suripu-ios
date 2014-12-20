
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
#import "HEMAlarmTableViewCell.h"

@interface HEMAlarmViewController()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIPickerView* pickerView;

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;

@property (nonatomic, strong) UILabel* selectedHourLabel;
@property (nonatomic, strong) UILabel* selectedMinuteLabel;
@property (nonatomic, strong) UILabel* selectedMeridiemLabel;
@end

@implementation HEMAlarmViewController

static NSUInteger const HEMAlarmHourIndex = 0;
static NSUInteger const HEMAlarmDividerIndex = 1;
static NSUInteger const HEMAlarmMinuteIndex = 2;
static NSUInteger const HEMAlarmMeridiemIndex = 3;
static NSUInteger const HEMAlarmMinuteIncrement = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.use12Hour = [SENSettings timeFormat] == SENTimeFormat12Hour;
    [self configureAlarmCache];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configurePicker];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:[HEMMainStoryboard pickSoundSegueIdentifier]]) {
        HEMAlarmSoundTableViewController* controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
    }
    else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        HEMAlarmRepeatTableViewController* controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
        controller.alarm = self.alarm;
    }
}

- (void)configureAlarmCache
{
    self.alarmCache = [HEMAlarmCache new];
    self.originalAlarmCache = [HEMAlarmCache new];
    if (self.alarm) {
        [self.alarmCache cacheValuesFromAlarm:self.alarm];
        [self.originalAlarmCache cacheValuesFromAlarm:self.alarm];
        self.unsavedAlarm = ![self.alarm isSaved];
    }
    if ([self isUnsavedAlarm])
        self.tableViewHeightConstraint.constant -= self.tableView.rowHeight;
}

- (void)configurePicker
{
    NSInteger minuteRow = self.alarmCache.minute / HEMAlarmMinuteIncrement;
    NSInteger hourRow = self.alarmCache.hour;
    NSInteger meridiemRow = self.alarmCache.hour <= 11 ? 0 : 1;
    if ([self shouldUse12Hour]) {
        if (hourRow > 12)
            hourRow -= 12;
        hourRow--;
    }
    [self.pickerView selectRow:hourRow inComponent:HEMAlarmHourIndex animated:NO];
    [self.pickerView selectRow:minuteRow
                   inComponent:HEMAlarmMinuteIndex animated:NO];

    self.selectedHourLabel = (id)[self.pickerView viewForRow:hourRow
                                                forComponent:HEMAlarmHourIndex];
    self.selectedMinuteLabel = (id)[self.pickerView viewForRow:minuteRow
                                                  forComponent:HEMAlarmMinuteIndex];
    [self configureLabel:self.selectedHourLabel
                selected:YES component:HEMAlarmHourIndex];
    [self configureLabel:self.selectedMinuteLabel
                selected:YES component:HEMAlarmMinuteIndex];
    if ([self shouldUse12Hour]) {
        [self.pickerView selectRow:meridiemRow
                       inComponent:HEMAlarmMeridiemIndex animated:NO];
        self.selectedMeridiemLabel = (id)[self.pickerView viewForRow:meridiemRow
                                                        forComponent:HEMAlarmMeridiemIndex];
        [self configureLabel:self.selectedMeridiemLabel
                    selected:YES component:HEMAlarmMeridiemIndex];
    }
}

- (struct SENAlarmTime)timeFromCachedValues
{
    return (struct SENAlarmTime){
        .hour = self.alarmCache.hour,
        .minute = self.alarmCache.minute
    };
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

- (IBAction)deleteAndDismissFromView:(id)sender
{
    [self.alarm delete];
    __weak typeof(self) weakSelf = self;
    [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success)
            [strongSelf dismiss:NO];
    }];
}

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    self.alarmCache.smart = [sender isOn];
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

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self isUnsavedAlarm] ? 3 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier, *title = nil, *detail = nil;
    BOOL switchState = NO;
    switch (indexPath.row) {
        case 0:
            identifier = [HEMMainStoryboard alarmSwitchCellReuseIdentifier];
            switchState = [self.alarmCache isSmart];
            title = NSLocalizedString(@"alarm.smart.title", nil);
            break;
        case 1:
            identifier = [HEMMainStoryboard alarmSoundCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.sound.title", nil);
            detail = self.alarmCache.soundName;
            break;
        case 2:
            identifier = [HEMMainStoryboard alarmRepeatCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.repeat.title", nil);
            detail = [HEMAlarmUtils repeatTextForUnitFlags:self.alarmCache.repeatFlags];
            break;
        case 3:
            identifier = [HEMMainStoryboard alarmDeleteCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.delete.title", nil);
    }
    HEMAlarmTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.titleLabel.text = title;
    cell.detailLabel.text = detail;
    cell.smartSwitch.on = switchState;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 4)
        [self deleteAndDismissFromView:nil];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row != 0;
}

#pragma mark - UIPickerView

- (void)configureLabel:(UILabel *)label selected:(BOOL)isSelected component:(NSUInteger)component
{
//    CGAffineTransform transform = isSelected ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.5f, 0.5f);
//    if (!CGAffineTransformEqualToTransform(label.transform, transform))
//        label.transform = transform;
    CGFloat fontSize;
    if (component == HEMAlarmMeridiemIndex) {
        fontSize = 20.f;
    } else if (isSelected) {
        fontSize = 72.f;
    } else {
        fontSize = 50.f;
    }
    label.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:fontSize];
    label.textColor = isSelected ? [HelloStyleKit lightSleepColor] : [UIColor grayColor];
}

- (void)updateAlarmCacheHourWithSelectedRow:(NSUInteger)row
{
    NSUInteger adjustedRow = row;
    if ([self shouldUse12Hour]) {
        NSString* pmText = [self textForRow:1 forComponent:HEMAlarmMeridiemIndex];
        if ([self.selectedMeridiemLabel.text isEqualToString:pmText]) {
            adjustedRow = row + 13;
        } else {
            adjustedRow = row + 1;
        }
        if (adjustedRow == 24)
            adjustedRow = 12;
        else if (adjustedRow == 12)
            adjustedRow = 0;
    }
    self.alarmCache.hour = adjustedRow;
}

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UILabel* oldSelectedLabel;
    UILabel* selectedLabel = (id)[pickerView viewForRow:row forComponent:component];
    switch (component) {
        case HEMAlarmHourIndex: {
            oldSelectedLabel = self.selectedHourLabel;
            self.selectedHourLabel = selectedLabel;
            [self updateAlarmCacheHourWithSelectedRow:row];
        } break;
        case HEMAlarmMinuteIndex: {
            oldSelectedLabel = self.selectedMinuteLabel;
            self.selectedMinuteLabel = selectedLabel;
            self.alarmCache.minute = row * HEMAlarmMinuteIncrement;
        } break;
        case HEMAlarmMeridiemIndex: {
            oldSelectedLabel = self.selectedMeridiemLabel;
            self.selectedMeridiemLabel = selectedLabel;
            NSUInteger selectedHourRow = [pickerView selectedRowInComponent:HEMAlarmHourIndex];
            [self updateAlarmCacheHourWithSelectedRow:selectedHourRow];
        } break;
        default:
            break;
    }
    if (![selectedLabel isEqual:oldSelectedLabel]) {
        [self configureLabel:selectedLabel selected:YES component:component];
        if (oldSelectedLabel)
            [self configureLabel:oldSelectedLabel selected:NO component:component];
        [self.pickerView setNeedsLayout];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case HEMAlarmDividerIndex: return 12.f;
        case HEMAlarmMeridiemIndex: return 40.f;
        default: return 90.f;
    }
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
        case HEMAlarmHourIndex: return [self shouldUse12Hour] ? 12 : 24;
        case HEMAlarmDividerIndex: return 1;
        case HEMAlarmMinuteIndex: return 60 / HEMAlarmMinuteIncrement;
        case HEMAlarmMeridiemIndex: return 2;
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
    BOOL isSelectedRow = (component == HEMAlarmHourIndex && [label.text isEqualToString:self.selectedHourLabel.text])
        || (component == HEMAlarmMinuteIndex && [label.text isEqualToString:self.selectedMinuteLabel.text])
        || (component == HEMAlarmDividerIndex)
        || (component == HEMAlarmMeridiemIndex && [label.text isEqualToString:self.selectedMeridiemLabel.text]);
    [self configureLabel:label selected:isSelectedRow component:component];
    return label;
}

- (NSString *)textForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case HEMAlarmHourIndex: {
            NSInteger hour = [self shouldUse12Hour] ? row + 1 : row;
            return [NSString stringWithFormat:@"%ld", hour];
        }
        case HEMAlarmMinuteIndex: {
            NSInteger minute = row * HEMAlarmMinuteIncrement;
            NSString* format = minute < 10 ? @"0%ld" : @"%ld";
            return [NSString stringWithFormat:format, minute];
        }
        case HEMAlarmMeridiemIndex: {
            NSString* format = row == 0 ? @"alarms.alarm.meridiem.am" : @"alarms.alarm.meridiem.pm";
            return [NSLocalizedString(format, nil) uppercaseString];
        }
        case HEMAlarmDividerIndex: return NSLocalizedString(@"alarm.clock.divider", nil);
        default: return nil;
    }
}

- (NSTextAlignment)textAlignmentForComponent:(NSInteger)component
{
    switch (component) {
        case HEMAlarmHourIndex: return NSTextAlignmentRight;
        case HEMAlarmMeridiemIndex: return NSTextAlignmentLeft;
        default: return NSTextAlignmentCenter;
    }
}

@end
