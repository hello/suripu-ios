
#import <SenseKit/SENAlarm.h>
#import "HEMSleepSoundTableViewController.h"
#import "HEMColorUtils.h"

static NSString* const SleepSoundCellIdentifier = @"sleepSoundCell";

@interface HEMSleepSoundTableViewController ()

@property (nonatomic, strong) NSArray* possibleSleepSounds;
@end

@implementation HEMSleepSoundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.possibleSleepSounds = @[ @"White Noise", @"Pink Noise", @"Ceiling Fan", @"Clothes Dryer", @"Rain", @"Ocean Waves" ];
    [self configureViewBackground];
}

- (void)configureViewBackground
{
    [self.view.layer insertSublayer:[HEMColorUtils layerWithBlueBackgroundGradientInFrame:self.view.bounds]
                            atIndex:0];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleSleepSounds.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SleepSoundCellIdentifier forIndexPath:indexPath];

    NSString* sleepSoundText = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    cell.textLabel.text = sleepSoundText;

    if ([sleepSoundText isEqualToString:[SENAlarm savedAlarm].soundName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - Table view delegate

// FIXME: obvi need to store the white noise sound somewhere
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger index = [self.possibleSleepSounds indexOfObject:[SENAlarm savedAlarm].soundName];
    if (indexPath.row == index)
        return;

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
