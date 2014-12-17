
#import <SenseKit/SENBackgroundNoise.h>
#import "HEMSleepSoundTableViewController.h"
#import "HelloStyleKit.h"

static NSString* const SleepSoundCellIdentifier = @"sleepSoundCell";

@interface HEMSleepSoundTableViewController ()

@property (nonatomic, strong) NSArray* possibleSleepSounds;
@end

@implementation HEMSleepSoundTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.possibleSleepSounds = @[ NSLocalizedString(@"noise.sound-name.none", nil), @"Ceiling Fan", @"Clothes Dryer", @"Ocean Waves", @"Pink Noise", @"Rain", @"White Noise" ];
    self.view.backgroundColor = [HelloStyleKit currentConditionsBackgroundColor];
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

    if ([sleepSoundText isEqualToString:[SENBackgroundNoise savedBackgroundNoise].soundName]) {
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
    NSUInteger index = [self.possibleSleepSounds indexOfObject:[SENBackgroundNoise savedBackgroundNoise].soundName];
    if (indexPath.row == index)
        return;

    SENBackgroundNoise* noise = [SENBackgroundNoise savedBackgroundNoise];
    noise.soundName = self.possibleSleepSounds[indexPath.row];
    [noise save];
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
