
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENSound.h>
#import <markdown_peg.h>

#import "HEMAlarmViewController.h"
#import "HEMAlertViewController.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMAlarmCache.h"
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

@interface HEMAlarmViewController () <UITableViewDelegate, UITableViewDataSource, HEMClockPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet HEMClockPickerView *clockView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

@property (nonatomic, strong) HEMAlarmCache *alarmCache;
@property (nonatomic, strong) HEMAlarmCache *originalAlarmCache;
@property (nonatomic, getter=isUnsavedAlarm) BOOL unsavedAlarm;
@property (nonatomic, getter=didLoadOnce) BOOL loadOnce;
@end

@implementation HEMAlarmViewController

static NSUInteger const HEMClockMinuteIncrement = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableView];
    [self configureAlarmCache];
    [self loadDefaultAlarmSound];
    [self configureButtonContainer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self didLoadOnce]) {
        [self configureClockView];
        self.loadOnce = YES;
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [HEMTutorial showTutorialForAlarmsIfNeededFrom:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:[HEMMainStoryboard pickSoundSegueIdentifier]]) {
        HEMAlarmSoundTableViewController *controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
    } else if ([segue.identifier isEqualToString:[HEMMainStoryboard alarmRepeatSegueIdentifier]]) {
        HEMAlarmRepeatTableViewController *controller = segue.destinationViewController;
        controller.alarmCache = self.alarmCache;
        controller.alarm = self.alarm;
    }
}

- (void)loadDefaultAlarmSound {
    [SENAPIAlarms availableSoundsWithCompletion:^(NSArray *data, NSError *error) {
      if (error)
          return;
      if (!self.alarmCache.soundID && data.count > 0) {
          SENSound *sound = [data firstObject];
          self.alarmCache.soundID = sound.identifier;
          self.alarmCache.soundName = sound.displayName;
          [self.tableView reloadData];
      }
    }];
}

- (void)configureButtonContainer {
    CALayer *layer = self.buttonContainerView.layer;
    layer.shadowRadius = 2.f;
    layer.shadowOffset = CGSizeMake(0, -2.f);
    layer.shadowOpacity = 0.05f;
}

- (void)configureTableView {
    CALayer *layer = self.tableView.layer;
    layer.shadowRadius = 2.f;
    layer.shadowOffset = CGSizeMake(0, 2.f);
    layer.shadowOpacity = 0.05f;
}

- (void)configureAlarmCache {
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

- (struct SENAlarmTime)timeFromCachedValues {
    return (struct SENAlarmTime){.hour = self.alarmCache.hour, .minute = self.alarmCache.minute };
}

#pragma mark - Actions

- (void)dismiss:(BOOL)saved {
    if (!saved) {
        self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        self.navigationController.transitioningDelegate = nil;
    }
    if (self.delegate) {
        if (saved) {
            [self.delegate didSaveAlarm:self.alarm from:self];
        } else { [self.delegate didCancelAlarmFrom:self]; }
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)dismissFromView:(id)sender {
    [self dismiss:NO];
}

- (IBAction)saveAndDismissFromView:(id)sender {
    if ([HEMAlarmUtils timeIsTooSoonByHour:self.alarmCache.hour minute:self.alarmCache.minute]) {
        [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"alarm.save-error.too-soon.title", nil)
                                                message:NSLocalizedString(@"alarm.save-error.too-soon.message", nil)
                                             controller:self];
        return;
    }

    self.alarmCache.on = YES;
    [self updateAlarmFromCache:self.alarmCache];
    __weak typeof(self) weakSelf = self;
    [HEMAlarmUtils
        updateAlarmsFromPresentingController:self
                                  completion:^(NSError *error) {
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    [SENAnalytics track:HEMAnalyticsEventSaveAlarm
                                             properties:@{
                                                 HEMAnalyticsEventSaveAlarmHour : @(self.alarmCache.hour),
                                                 HEMAnalyticsEventSaveAlarmMinute : @(self.alarmCache.minute)
                                             }];
                                    if (error) {
                                        [SENAnalytics trackError:error];
                                    }
                                    if (!error)
                                        [strongSelf dismiss:YES];
                                    else if ([strongSelf isUnsavedAlarm])
                                        [strongSelf.alarm delete];
                                    else
                                        [strongSelf updateAlarmFromCache:strongSelf.originalAlarmCache];
                                  }];
}

- (IBAction)deleteAndDismissFromView:(id)sender {
    NSString *title = NSLocalizedString(@"alarm.delete.confirm.title", nil);
    NSString *message = NSLocalizedString(@"alarm.delete.confirm.message", nil);
    HEMAlertViewController *dialogVC = [HEMAlertViewController new];
    [dialogVC setTitle:title];
    [dialogVC setMessage:message];
    [dialogVC setDefaultButtonTitle:NSLocalizedString(@"actions.yes", nil)];
    [dialogVC setViewToShowThrough:self.view];
    [dialogVC addAction:NSLocalizedString(@"actions.no", nil)
                primary:NO
            actionBlock:nil];

    __weak typeof(self) weakSelf = self;
    [dialogVC showFrom:self onDefaultActionSelected:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.alarm delete];
        [HEMAlarmUtils updateAlarmsFromPresentingController:strongSelf completion:^(NSError *error) {
            if (error) {
                [strongSelf.alarm save];
            } else {
                [strongSelf dismiss:NO];
            }
        }];
    }];
}

- (IBAction)updateAlarmState:(UISwitch *)sender {
    BOOL isSmart = [sender isOn];
    self.alarmCache.smart = isSmart;
    [SENAnalytics track:HEMAnalyticsEventSwitchSmartAlarm
             properties:@{
                 HEMAnalyticsEventSwitchSmartAlarmOn : @(isSmart)
             }];
}

- (IBAction)showHelpfulDialogAboutSmartness:(id)sender {
    [HEMTutorial showTutorialForAlarmSmartnessFrom:self];
}

- (void)updateAlarmFromCache:(HEMAlarmCache *)cache {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self isUnsavedAlarm] ? 3 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier, *title = nil, *detail = nil;
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
    HEMAlarmTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.titleLabel.text = title;
    cell.detailLabel.text = detail;
    cell.smartSwitch.on = switchState;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == HEMAlarmTableIndexDeletion)
        [self deleteAndDismissFromView:nil];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != HEMAlarmTableIndexSmart;
}

#pragma mark - HEMClockPickerViewDelegate

- (void)configureClockView {
    self.clockView.delegate = self;
    self.clockView.minuteIncrement = HEMClockMinuteIncrement;
    [self.clockView updateTimeToHour:self.alarmCache.hour minute:self.alarmCache.minute];
}

- (void)didUpdateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute {
    self.alarmCache.hour = hour;
    self.alarmCache.minute = minute;
}

@end
