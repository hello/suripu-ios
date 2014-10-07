
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmRepeatTableViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmRepeatTableViewController ()

@property (nonatomic, strong) NSArray* repeatOptions;
@property (nonatomic, strong) NSMutableArray* selectedRepeatOptions;
@end

@implementation HEMAlarmRepeatTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"alarm.repeat.title", nil);
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

- (SENAlarmRepeatDays)repeatDayForIndexPath:(NSIndexPath*)indexPath
{
    return 1UL << (indexPath.row + 1);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.repeatOptions.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard alarmChoiceCellReuseIdentifier] forIndexPath:indexPath];

    NSString* text = [self.repeatOptions objectAtIndex:indexPath.row];
    NSUInteger day = [self repeatDayForIndexPath:indexPath];
    NSUInteger repeatFlags = [self.cachedAlarmValues[@"repeat"] unsignedIntegerValue];
    cell.textLabel.text = text;

    if ((repeatFlags & day) == day) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger day = [self repeatDayForIndexPath:indexPath];
    NSUInteger repeatFlags = [self.cachedAlarmValues[@"repeat"] unsignedIntegerValue];
    if ((repeatFlags & day) == day) {
        repeatFlags -= day;
    } else {
        repeatFlags |= day;
    }
    self.cachedAlarmValues[@"repeat"] = @(repeatFlags);
    [tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
}

@end
