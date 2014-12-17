
#import <SenseKit/SENAlarm.h>

#import "UIFont+HEMStyle.h"

#import "HEMAlarmListViewController.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmListTableViewCell.h"
#import "HelloStyleKit.h"
#import "HEMAlarmAddButton.h"
#import "HEMAlarmUtils.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (strong, nonatomic) NSArray* alarms;
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton* addButton;
@end

@implementation HEMAlarmListViewController

static NSUInteger HEMAlarmListLimit = 8;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.title = NSLocalizedString(@"alarms.title", nil);
        self.tabBarItem.image = [HelloStyleKit alarmBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [HEMAlarmUtils refreshAlarmsFromPresentingController:self completion:^{
        [self reloadData];
        [self.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)reloadData
{
    self.alarms = [[SENAlarm savedAlarms] sortedArrayUsingComparator:^NSComparisonResult(SENAlarm* obj1, SENAlarm* obj2) {
        NSNumber* alarmValue1 = @(obj1.hour * 60 + obj1.minute);
        NSNumber* alarmValue2 = @(obj2.hour * 60 + obj2.minute);
        return [alarmValue1 compare:alarmValue2];
    }];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

#pragma mark - Actions

- (IBAction)addNewAlarm:(id)sender
{
    SENAlarm* alarm = [SENAlarm createDefaultAlarm];
    [self presentViewControllerForAlarm:alarm];
}

- (IBAction)flippedEnabledSwitch:(UISwitch*)sender
{
    __block SENAlarm* alarm = [self.alarms objectAtIndex:sender.tag];
    BOOL on = [sender isOn];
    alarm.on = on;
    [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
        if (!success) {
            alarm.on = !on;
            sender.on = !on;
        }
    }];
}

- (void)presentViewControllerForAlarm:(SENAlarm*)alarm
{
    UINavigationController* controller = (UINavigationController*)[HEMMainStoryboard instantiateAlarmNavController];
    HEMAlarmViewController* alarmController = (HEMAlarmViewController*)controller.topViewController;
    alarmController.alarm = alarm;
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alarms.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
    HEMAlarmListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard alarmListCellIdentifier]];
    cell.timeLabel.text = [alarm localizedValue];
    cell.timeLabel.font = [UIFont settingsTitleFont];
    
    cell.detailLabel.text = [HEMAlarmUtils repeatTextForUnitFlags:alarm.repeatFlags];
    cell.detailLabel.font = [UIFont settingsTableCellDetailFont];
    
    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.row;
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
        [alarm delete];
        [self reloadData];
        __weak typeof(self) weakSelf = self;
        [HEMAlarmUtils updateAlarmsFromPresentingController:self completion:^(BOOL success) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!success) {
                [alarm save];
                [strongSelf reloadData];
                [strongSelf.tableView reloadData];
            }
        }];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
    [self presentViewControllerForAlarm:alarm];
}

@end
