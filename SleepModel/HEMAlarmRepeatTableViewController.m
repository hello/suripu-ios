
#import <SenseKit/SENAlarm.h>

#import "UIFont+HEMStyle.h"

#import "HEMAlarmRepeatTableViewController.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmCache.h"
#import "HEMAlarmUtils.h"
#import "HEMAlarmPropertyTableViewCell.h"
#import "HelloStyleKit.h"

@interface HEMAlarmRepeatTableViewController ()

@property (nonatomic, strong) NSArray *repeatOptions;
@property (nonatomic, strong) NSMutableArray *selectedRepeatOptions;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;
@end

@implementation HEMAlarmRepeatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"alarm.repeat.title", nil);
    self.lineViewHeightConstraint.constant = 0.5;
    self.tableView.tableFooterView = [UIView new];
    self.repeatOptions = @[
        NSLocalizedString(@"alarm.repeat.days.sunday", nil),
        NSLocalizedString(@"alarm.repeat.days.monday", nil),
        NSLocalizedString(@"alarm.repeat.days.tuesday", nil),
        NSLocalizedString(@"alarm.repeat.days.wednesday", nil),
        NSLocalizedString(@"alarm.repeat.days.thursday", nil),
        NSLocalizedString(@"alarm.repeat.days.friday", nil),
        NSLocalizedString(@"alarm.repeat.days.saturday", nil),
    ];
}

- (SENAlarmRepeatDays)repeatDayForIndexPath:(NSIndexPath *)indexPath {
    return 1UL << (indexPath.row + 1);
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repeatOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmChoiceCellReuseIdentifier];
    HEMAlarmPropertyTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    NSString *text = [self.repeatOptions objectAtIndex:indexPath.row];
    NSUInteger day = [self repeatDayForIndexPath:indexPath];
    cell.titleLabel.text = text;
    cell.disclosureImageView.hidden = (self.alarmCache.repeatFlags & day) != day;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger day = [self repeatDayForIndexPath:indexPath];
    NSUInteger repeatFlags = self.alarmCache.repeatFlags;
    if ((repeatFlags & day) == day) {
        repeatFlags -= day;
    } else if ([self isValidDayToAdd:day]) { repeatFlags |= day; }
    self.alarmCache.repeatFlags = repeatFlags;
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)isValidDayToAdd:(SENAlarmRepeatDays)day {
    if (![self.alarmCache isSmart])
        return YES;
    return [HEMAlarmUtils areRepeatDaysValid:day forSmartAlarm:self.alarm presentingControllerForErrors:self];
}

@end
