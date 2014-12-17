
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
    [self.addButton addTarget:self action:@selector(touchDownAddAlarmButton:)
             forControlEvents:UIControlEventTouchDown];
    [self.addButton addTarget:self action:@selector(touchUpOutsideAddAlarmButton:)
             forControlEvents:UIControlEventTouchUpOutside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self touchUpOutsideAddAlarmButton:nil];
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

- (void)touchDownAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.15f animations:^{
        self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMinimumScale,
                                                                HEMAlarmListButtonMinimumScale, 1.f);
    }];
}

static CGFloat const HEMAlarmListButtonMinimumScale = 0.8f;
static CGFloat const HEMAlarmListButtonMaximumScale = 1.4f;
- (void)touchUpOutsideAddAlarmButton:(id)sender
{
    [UIView animateWithDuration:0.2f animations:^{
        self.addButton.layer.transform = CATransform3DIdentity;
    }];
}

- (IBAction)addNewAlarm:(id)sender
{
    void (^animations)() = ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.75 animations:^{
            self.addButton.layer.transform = CATransform3DMakeScale(HEMAlarmListButtonMaximumScale,
                                                                    HEMAlarmListButtonMaximumScale, 1.f);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
            self.addButton.layer.transform = CATransform3DIdentity;
        }];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        SENAlarm* alarm = [SENAlarm createDefaultAlarm];
        [self presentViewControllerForAlarm:alarm];
    };

    [UIView animateKeyframesWithDuration:0.25
                                   delay:0
                                 options:(UIViewKeyframeAnimationOptionCalculationModeCubicPaced|UIViewAnimationOptionCurveEaseInOut)
                              animations:animations
                              completion:completion];
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
    NSString* identifier = [HEMMainStoryboard alarmListCellIdentifier];
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
    HEMAlarmListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
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

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath*)indexPath
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
