
#import <SenseKit/SENAlarm.h>

#import "HEMAlarmListViewController.h"
#import "HEMAlarmViewController.h"
#import "HEMAlarmListTableViewCell.h"
#import "HelloStyleKit.h"
#import "HEMColorUtils.h"
#import "HEMAlarmAddButton.h"
#import "HEMAlarmTextUtils.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) CAGradientLayer* gradientLayer;
@property (strong, nonatomic) NSArray* alarms;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet HEMAlarmAddButton *addButton;
@end

@implementation HEMAlarmListViewController

static NSUInteger HEMAlarmListLimit = 8;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = NSLocalizedString(@"alarms.title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[HelloStyleKit chevronIconLeft] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.addButton setTitleColor:[UIColor colorWithWhite:0.9 alpha:0.25] forState:UIControlStateDisabled];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self configureViewBackground];
    [self reloadData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)configureViewBackground
{
    if (!self.gradientLayer) {
        self.gradientLayer = [CAGradientLayer new];
        [self.view.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    self.gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    [HEMColorUtils configureLayer:self.gradientLayer forHourOfDay:7];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)reloadData
{
    self.alarms = [[SENAlarm savedAlarms] sortedArrayUsingComparator:^NSComparisonResult(SENAlarm *obj1, SENAlarm *obj2) {
        NSNumber* alarmValue1 = @(obj1.hour * 60 + obj1.minute);
        NSNumber* alarmValue2 = @(obj2.hour * 60 + obj2.minute);
        return [alarmValue1 compare:alarmValue2];
    }];
    self.addButton.enabled = self.alarms.count < HEMAlarmListLimit;
}

#pragma mark - Actions

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addNewAlarm:(id)sender
{
    SENAlarm* alarm = [SENAlarm createDefaultAlarm];
    [self presentViewControllerForAlarm:alarm];
}

- (IBAction)flippedEnabledSwitch:(UISwitch *)sender {
    SENAlarm* alarm = [self.alarms objectAtIndex:sender.tag];
    alarm.on = [sender isOn];
}

- (void)presentViewControllerForAlarm:(SENAlarm*)alarm {
    UINavigationController* controller = (UINavigationController*)[HEMMainStoryboard instantiateAlarmNavController];
    HEMAlarmViewController* alarmController = (HEMAlarmViewController*)controller.topViewController;
    alarmController.alarm = alarm;
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.alarms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
    HEMAlarmListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard alarmListCellIdentifier]];
    cell.timeLabel.text = [alarm localizedValue];
    cell.detailLabel.text = [HEMAlarmTextUtils repeatTextForUnitFlags:alarm.repeatFlags];
    cell.enabledSwitch.on = [alarm isOn];
    cell.enabledSwitch.tag = indexPath.row;
    return cell;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
        [alarm delete];
        [self reloadData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    SENAlarm* alarm = [self.alarms objectAtIndex:indexPath.row];
    [self presentViewControllerForAlarm:alarm];
}

@end
