
#import <SenseKit/SENAlarm.h>
#import "HEMAlarmSoundTableViewController.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

static NSString* const SleepCellIdentifier = @"sleepSoundCell";

@interface HEMAlarmSoundTableViewController ()
@property (nonatomic, strong) NSArray* possibleSleepSounds;
@end

@implementation HEMAlarmSoundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
    self.possibleSleepSounds = @[ @"None", @"Bells", @"Birdsong", @"Chime", @"Waterfall" ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleSleepSounds.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SleepCellIdentifier forIndexPath:indexPath];

    NSString* sleepSoundText = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    cell.textLabel.text = sleepSoundText;

    if ([sleepSoundText isEqualToString:self.alarm.soundName]) {
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
    NSUInteger index = [self.possibleSleepSounds indexOfObject:self.alarm.soundName];
    if (indexPath.row == index)
        return;

    self.alarm.soundName = [self.possibleSleepSounds objectAtIndex:indexPath.row];
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
