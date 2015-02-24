
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENSound.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMAlarmCache.h"
#import "HelloStyleKit.h"
#import "HEMAlarmUtils.h"
#import "UIColor+HEMStyle.h"
#import "UIFont+HEMStyle.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmTableViewCell.h"
#import "HEMClockPickerView.h"
#import "HEMTutorial.h"

typedef NS_ENUM(NSUInteger, HEMAlarmTableIndex) {
    HEMAlarmTableIndexSmart = 0,
    HEMAlarmTableIndexSound = 1,
    HEMAlarmTableIndexRepeat = 2,
    HEMAlarmTableIndexDeletion = 3,
};

@interface HEMAlarmViewController()<UITableViewDelegate, UITableViewDataSource, HEMClockPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* lineViewHeightConstraint;
@property (weak, nonatomic) IBOutlet HEMClockPickerView* clockView;

@property (nonatomic, strong) HEMAlarmCache* alarmCache;
@property (nonatomic, strong) HEMAlarmCache* originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;

@end

@implementation HEMAlarmViewController

static NSUInteger const HEMClockMinuteIncrement = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lineViewHeightConstraint.constant = 0.5;
    [self configureAlarmCache];
    [self loadDefaultAlarmSound];
    [self configureBarButtonItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureClockView];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [HEMTutorial showTutorialForAlarmsIfNeeded];
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

- (void)configureBarButtonItems
{
    static CGFloat const HEMAlarmBarButtonSpace = 12.f;
    UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    leftFixedSpace.width = HEMAlarmBarButtonSpace;
    UIBarButtonItem *rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
    rightFixedSpace.width = HEMAlarmBarButtonSpace;
    UIBarButtonItem* leftItem = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = @[leftFixedSpace, leftItem];
    UIBarButtonItem* rightItem = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItems = @[rightFixedSpace, rightItem];
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
    HEMAlertViewController* dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setMessage:message];
    [dialogVC setDefaultButtonTitle:NSLocalizedString(@"actions.no", nil)];
    [dialogVC setViewToShowThrough:self.view];
    __weak typeof(self) weakSelf = self;
    [dialogVC addAction:NSLocalizedString(@"actions.yes", nil) primary:NO actionBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.alarm delete];
        [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
            if (success) {
                [strongSelf dismissViewControllerAnimated:YES completion:^{
                    [strongSelf dismiss:NO];
                }];
            } else {
                [strongSelf.alarm save];
            }
        }];
    }];

    [dialogVC showFrom:self onDefaultActionSelected:^{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (IBAction)updateAlarmState:(UISwitch*)sender
{
    self.alarmCache.smart = [sender isOn];
}

- (IBAction)showHelpfulDialogAboutSmartness:(id)sender
{
    [HEMTutorial showTutorialForAlarmSmartness];
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
        case HEMAlarmTableIndexSmart:
            identifier = [HEMMainStoryboard alarmSwitchCellReuseIdentifier];
            switchState = [self.alarmCache isSmart];
            title = NSLocalizedString(@"alarm.smart.title", nil);
            break;
        case HEMAlarmTableIndexSound:
            identifier = [HEMMainStoryboard alarmSoundCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.sound.title", nil);
            detail = self.alarmCache.soundName ?: NSLocalizedString(@"alarm.sound.no-selection", nil);
            break;
        case HEMAlarmTableIndexRepeat:
            identifier = [HEMMainStoryboard alarmRepeatCellReuseIdentifier];
            title = NSLocalizedString(@"alarm.repeat.title", nil);
            detail = [HEMAlarmUtils repeatTextForUnitFlags:self.alarmCache.repeatFlags];
            break;
        case HEMAlarmTableIndexDeletion:
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
    if (indexPath.row == HEMAlarmTableIndexDeletion)
        [self deleteAndDismissFromView:nil];
}

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.row != HEMAlarmTableIndexSmart;
}

#pragma mark - HEMClockPickerViewDelegate

- (void)configureClockView
{
    self.clockView.delegate = self;
    self.clockView.minuteIncrement = HEMClockMinuteIncrement;
    [self.clockView updateTimeToHour:self.alarmCache.hour minute:self.alarmCache.minute];
}

- (void)didUpdateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute
{
    self.alarmCache.hour = hour;
    self.alarmCache.minute = minute;
}

@end
