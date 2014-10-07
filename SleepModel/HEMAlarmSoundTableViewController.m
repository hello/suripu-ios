
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmSoundTableViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"

@interface HEMAlarmSoundTableViewController ()
@property (nonatomic, strong) NSArray* possibleSleepSounds;
@end

@implementation HEMAlarmSoundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setTableFooterView:[[UIView alloc] init]];
    self.possibleSleepSounds = @[ @"None", @"Bells", @"Birdsong", @"Chime", @"Waterfall" ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleSleepSounds.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard alarmChoiceCellReuseIdentifier] forIndexPath:indexPath];

    NSString* sleepSoundText = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    cell.textLabel.text = sleepSoundText;

    if ([sleepSoundText isEqualToString:self.cachedAlarmValues[@"sound"]]) {
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
    NSString* soundName = self.cachedAlarmValues[@"sound"];
    NSUInteger index = [self.possibleSleepSounds indexOfObject:soundName];
    if (indexPath.row == index)
        return;

    self.cachedAlarmValues[@"sound"] = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    if (index != NSNotFound) {
        NSArray* indexPaths = @[
            [NSIndexPath indexPathForRow:index inSection:0],
            indexPath
        ];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [tableView reloadData];
    }
}

@end
