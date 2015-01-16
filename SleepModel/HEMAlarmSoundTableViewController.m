
#import <AVFoundation/AVFoundation.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSound.h>
#import <SpinKit/RTSpinKitView.h>

#import "UIFont+HEMStyle.h"
#import "HEMAlarmSoundTableViewController.h"
#import "HEMAlarmPropertyTableViewCell.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmCache.h"
#import "HEMAlertController.h"

@interface HEMAlarmSoundTableViewController () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSArray* possibleSleepSounds;
@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSOperationQueue* loadingQueue;
@property (nonatomic, strong) NSIndexPath* loadingIndexPath;
@end

@implementation HEMAlarmSoundTableViewController

static NSString* const HEMAlarmSoundFormat = @"m4a";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loadingQueue = [NSOperationQueue new];
    self.loadingQueue.maxConcurrentOperationCount = 1;
    [self loadAlarmSounds];
    [[self tableView] setTableFooterView:[[UIView alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAudio];
}

- (void)loadAlarmSounds
{
    [self loadAlarmSoundsWithRetryCount:3];
}

- (void)loadAlarmSoundsWithRetryCount:(NSInteger)count
{
    if ([self isLoading])
        return;
    self.navigationItem.rightBarButtonItem = nil;
    self.loading = YES;
    __weak typeof(self) weakSelf = self;
    [SENAPIAlarms availableSoundsWithCompletion:^(NSArray* sounds, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            [strongSelf updateTableWithSounds:sounds];
            strongSelf.loading = NO;
            return;
        }
        strongSelf.loading = NO;
        if (count > 0)
            [strongSelf loadAlarmSoundsWithRetryCount:count - 1];
        else
            [strongSelf showAlertForError:error];
    }];
}

- (void)updateTableWithSounds:(NSArray*)sounds
{
    self.possibleSleepSounds = [sounds sortedArrayUsingComparator:^NSComparisonResult(SENSound* obj1, SENSound* obj2) {
        return [obj1.displayName compare:obj2.displayName];
    }];
    [self.tableView reloadData];
}

- (void)showAlertForError:(NSError*)error
{
    DDLogError(@"Failed to load alarm sounds: %@", error.localizedDescription);
    [HEMAlertController presentInfoAlertWithTitle:NSLocalizedString(@"alarm.sounds.error.title", nil)
                                          message:NSLocalizedString(@"alarm.sounds.error.message", nil)
                             presentingController:self];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(loadAlarmSounds)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.possibleSleepSounds.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString* identifier = [HEMMainStoryboard alarmChoiceCellReuseIdentifier];
    HEMAlarmPropertyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                                          forIndexPath:indexPath];

    SENSound* sound = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    cell.titleLabel.text = sound.displayName;
    cell.disclosureImageView.hidden = ![sound.displayName isEqualToString:self.alarmCache.soundName];
    if ([self.loadingIndexPath isEqual:indexPath])
        [cell.loadingIndicatorView startAnimating];
    else
        [cell.loadingIndicatorView stopAnimating];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger previousSelectionIndex = NSNotFound;
    for (int i = 0; i < self.possibleSleepSounds.count; i++) {
        SENSound* sound = self.possibleSleepSounds[i];
        if ([sound.displayName isEqualToString:self.alarmCache.soundName]) {
            previousSelectionIndex = i;
            if (indexPath.row == previousSelectionIndex)
                return;
            break;
        }
    }

    SENSound* sound = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    self.alarmCache.soundName = sound.displayName;
    self.alarmCache.soundID = sound.identifier;
    self.loadingIndexPath = indexPath;
    if (previousSelectionIndex != NSNotFound) {
        NSArray* indexPaths = @[
            [NSIndexPath indexPathForRow:previousSelectionIndex inSection:0],
            indexPath
        ];
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [tableView reloadData];
    }
    [self playAudioForSound:sound atIndexPath:indexPath];
}

#pragma mark - Audio

- (void)playAudioForSound:(SENSound*)sound atIndexPath:(NSIndexPath*)indexPath
{
    [self stopAudio];
    [self.loadingQueue cancelAllOperations];
    NSURL* url = [NSURL URLWithString:sound.URLPath];

    __weak typeof(self) weakSelf = self;
    [self.loadingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSData* urlData = [NSData dataWithContentsOfURL:url];
        if (!urlData) {
            [strongSelf stopLoadingAnimation];
            return;
        }

        [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
            [strongSelf stopLoadingAnimation];
            NSError* error = nil;
            strongSelf.player = [[AVAudioPlayer alloc] initWithData:urlData error:&error];
            strongSelf.player.delegate = self;
            if (error)
                [strongSelf stopAudio];
            else
                [strongSelf playAudio];
        }]];
    }]];
}

- (void)playAudio
{
    [self.player play];
}

- (void)stopAudio
{
    [self.player stop];
    self.player = nil;
}

- (void)stopLoadingAnimation
{
    if (self.loadingIndexPath) {
        NSIndexPath* indexPath = self.loadingIndexPath;
        self.loadingIndexPath = nil;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
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
