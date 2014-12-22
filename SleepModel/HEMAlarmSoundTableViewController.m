
#import <SenseKit/SENAlarm.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "UIFont+HEMStyle.h"

#import "HEMAlarmSoundTableViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmCache.h"

@interface HEMAlarmSoundTableViewController () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSArray* possibleSleepSounds;
@property (nonatomic, strong) AVAudioPlayer* player;
@end

@implementation HEMAlarmSoundTableViewController

static NSString* const HEMAlarmSoundFormat = @"m4a";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setTableFooterView:[[UIView alloc] init]];
    self.possibleSleepSounds = @[ @"None", @"Aria", @"Ballad", @"Bells" ];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAudio];
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

    if ([sleepSoundText isEqualToString:self.alarmCache.soundName]) {
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
    NSUInteger index = [self.possibleSleepSounds indexOfObject:self.alarmCache.soundName];
    if (indexPath.row == index)
        return;

    NSString* soundName = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    self.alarmCache.soundName = soundName;
    [self playAudioWithName:soundName];
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

#pragma mark - Audio

- (void)playAudioWithName:(NSString*)name
{
    [self stopAudio];
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:HEMAlarmSoundFormat];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return;

    [self playAudioFromURL:[NSURL fileURLWithPath:path]];
}

- (void)playAudioFromURL:(NSURL*)url
{
    [self stopAudio];
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    if (error)
        [self stopAudio];
    else
        [self.player play];
}

- (void)stopAudio
{
    [self.player stop];
    self.player = nil;
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self stopAudio];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self stopAudio];
}

@end
