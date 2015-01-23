
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSound.h>
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
#import "HEMAlertController.h"
#import "HEMAlarmTableViewCell.h"

@interface HEMAlarmViewController()<UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIPickerView* pickerView;
@property (weak, nonatomic) IBOutlet UIView* pickerContainerView;
@property (weak, nonatomic) IBOutlet UIView* gradientView;

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;
@property (nonatomic, getter=shouldUse12Hour) BOOL use12Hour;

@property (nonatomic, strong) UILabel* selectedHourLabel;
@property (nonatomic, strong) UILabel* selectedMinuteLabel;
@property (nonatomic, strong) UILabel* selectedMeridiemLabel;
@end

@implementation HEMAlarmViewController

static CGFloat const HEMAlarmPickerRowHeight = 80.f;
static CGFloat const HEMAlarmPickerDividerWidth = 12.f;
static CGFloat const HEMAlarmPickerMeridiemWidth = 60.f;
static CGFloat const HEMAlarmPickerDefaultWidth = 90.f;
static CGFloat const HEMAlarmPickerExpandedWidth = 120.f;
static NSUInteger const HEMAlarmTableSmartIndex = 0;
static NSUInteger const HEMAlarmTableSoundIndex = 1;
static NSUInteger const HEMAlarmTableRepeatIndex = 2;
static NSUInteger const HEMAlarmTableDeletionIndex = 3;
static NSUInteger const HEMAlarmHourIndex = 0;
static NSUInteger const HEMAlarmDividerIndex = 1;
static NSUInteger const HEMAlarmMinuteIndex = 2;
static NSUInteger const HEMAlarmMeridiemIndex = 3;
static NSUInteger const HEMAlarmMinuteIncrement = 5;
static NSUInteger const HEMAlarmMinuteCount = 60;
static NSUInteger const HEMAlarm12HourCount = 12;
static NSUInteger const HEMAlarm24HourCount = 24;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.use12Hour = [SENSettings timeFormat] == SENTimeFormat12Hour;
    [self configurePickerContainerView];
    [self configureAlarmCache];
    [self loadDefaultAlarmSound];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePicker];
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

- (void)loadDefaultAlarmSound
{
    [SENAPIAlarms availableSoundsWithCompletion:^(NSArray* data, NSError *error) {
        if (error)
            return;
        if (!self.alarmCache.soundID && data.count > 0) {
            SENSound* sound = [data firstObject];
            self.alarmCache.soundID = sound.identifier;
            self.alarmCache.soundName = sound.displayName;
            [self.tableView reloadData];
        }
    }];
}

- (void)configurePickerContainerView
{
    self.pickerContainerView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.f].CGColor;
    self.pickerContainerView.layer.borderWidth = 0.5f;
    NSArray* colors = @[
        (id)[UIColor colorWithWhite:0.98f alpha:1.f].CGColor,
        (id)[UIColor whiteColor].CGColor,
        (id)[UIColor whiteColor].CGColor,
        (id)[UIColor colorWithWhite:0.98f alpha:1.f].CGColor,
    ];

    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.colors = colors;
    layer.frame = self.gradientView.bounds;
    layer.locations = @[ @0, @(0.4), @(0.6), @1 ];
    layer.startPoint = CGPointZero;
    layer.endPoint = CGPointMake(0, 1);
    [self.gradientView.layer insertSublayer:layer atIndex:0];
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
    self.alarmCache.on = YES;
    if (![self isAlarmCacheValid])
        return;

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
    NSString* title = NSLocalizedString(@"alarm.delete.confirm.title", nil);
    NSString* message = NSLocalizedString(@"alarm.delete.confirm.message", nil);
    HEMAlertControllerStyle style = HEMAlertControllerStyleAlert;
    HEMAlertController* alertController = [[HEMAlertController alloc] initWithTitle:title
                                                                            message:message
                                                                              style:style
                                                               presentingController:self];

    __weak typeof(self) weakSelf = self;
    [alertController addActionWithText:NSLocalizedString(@"actions.no", nil) block:NULL];
    [alertController addActionWithText:NSLocalizedString(@"actions.yes", nil) block:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.alarm delete];
        [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
            if (success)
                [strongSelf dismiss:NO];
            else
                [strongSelf.alarm save];
        }];
    }];
    [alertController show];
}

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    BOOL on = [sender isOn];
    self.alarmCache.smart = on;
    if (on && ![self isAlarmCacheValid]) {
        self.alarmCache.smart = NO;
        sender.on = NO;
    }
}

- (BOOL)isAlarmCacheValid
{
    if ([self.alarmCache isSmart]) {
        SENAlarmRepeatDays days = [HEMAlarmUtils repeatDaysForAlarmCache:self.alarmCache];
        return [HEMAlarmUtils areRepeatDaysValid:days
                                   forSmartAlarm:self.alarm
                   presentingControllerForErrors:self];
    }

    return YES;
}

- (void)updateAlarmFromCache:(HEMAlarmCache*)cache
{
    self.alarm.smartAlarm = [cache isSmart];
    self.alarm.minute = cache.minute;
    self.alarm.hour = cache.hour;
    self.alarm.repeatFlags = cache.repeatFlags;
    self.alarm.soundName = cache.soundName;
    self.alarm.soundID = cache.soundID;
    self.alarm.on = cache.on;
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
        case HEMAlarmTableSmartIndex:
            identifier = [HEMMainStoryboard alarmSwitchCellReuseIdentifier];
            switchState = [self.alarmCache isSmart];
            title = NSLocalizedString(@"alarm.smart.title", nil);
            break;
        case HEMAlarmTableSoundIndex:
            identifier = [HEMMainStoryboard alarmSoundCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.sound.title", nil);
            detail = self.alarmCache.soundName ?: NSLocalizedString(@"alarm.sound.no-selection", nil);
            break;
        case HEMAlarmTableRepeatIndex:
            identifier = [HEMMainStoryboard alarmRepeatCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.repeat.title", nil);
            detail = [HEMAlarmUtils repeatTextForUnitFlags:self.alarmCache.repeatFlags];
            break;
        case HEMAlarmTableDeletionIndex:
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
    if (indexPath.row == HEMAlarmTableDeletionIndex)
        [self deleteAndDismissFromView:nil];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row != HEMAlarmTableSmartIndex;
}

#pragma mark - UIPickerView

- (void)updatePicker
{
    NSInteger minuteRow = self.alarmCache.minute / HEMAlarmMinuteIncrement;
    NSInteger hourRow = self.alarmCache.hour;
    NSInteger meridiemRow = self.alarmCache.hour <= (HEMAlarm12HourCount - 1) ? 0 : 1;
    if ([self shouldUse12Hour]) {
        if (hourRow > HEMAlarm12HourCount)
            hourRow -= HEMAlarm12HourCount;
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

- (void)configureLabel:(UILabel *)label selected:(BOOL)isSelected component:(NSUInteger)component
{
    if (component == HEMAlarmMeridiemIndex) {
        label.font = [UIFont alarmMeridiemFont];
    } else {
        label.font = [UIFont alarmNumberFont];
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.4f, 1.4f);
        CGAffineTransform selectedTransform;
        if (component == HEMAlarmHourIndex)
            selectedTransform = CGAffineTransformTranslate(scaleTransform, -CGRectGetWidth(label.bounds)/7, 0);
        else
            selectedTransform = scaleTransform;
        CGAffineTransform transform = isSelected ? selectedTransform : CGAffineTransformIdentity;
        if (!CGAffineTransformEqualToTransform(transform, label.transform))
            label.transform = transform;
    }
    label.textColor = isSelected ? [HelloStyleKit barButtonEnabledColor] : [UIColor grayColor];
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
        [UIView animateWithDuration:0.25f animations:^{
            [self configureLabel:selectedLabel selected:YES component:component];
            if (oldSelectedLabel)
                [self configureLabel:oldSelectedLabel selected:NO component:component];
        } completion:^(BOOL finished) {
            [self.pickerView setNeedsLayout];
        }];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (component) {
        case HEMAlarmDividerIndex: return HEMAlarmPickerDividerWidth;
        case HEMAlarmMeridiemIndex: return HEMAlarmPickerMeridiemWidth;
        case HEMAlarmMinuteIndex: {
            if (![self shouldUse12Hour])
                return HEMAlarmPickerExpandedWidth;
        }
        default: return HEMAlarmPickerDefaultWidth;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return HEMAlarmPickerRowHeight;
}

#pragma mark UIPickerViewDatasource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self shouldUse12Hour] ? 4 : 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case HEMAlarmHourIndex: return [self shouldUse12Hour] ? HEMAlarm12HourCount : HEMAlarm24HourCount;
        case HEMAlarmDividerIndex: return 1;
        case HEMAlarmMinuteIndex: return HEMAlarmMinuteCount / HEMAlarmMinuteIncrement;
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
        case HEMAlarmHourIndex:
            return NSTextAlignmentRight;
        case HEMAlarmDividerIndex:
        case HEMAlarmMeridiemIndex:
            return NSTextAlignmentLeft;
        case HEMAlarmMinuteIndex: {
            if (![self shouldUse12Hour])
                return NSTextAlignmentLeft;
        }
        default: return NSTextAlignmentCenter;
    }
}

@end
