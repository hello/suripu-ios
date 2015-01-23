
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
    static NSArray* alarmSounds = nil;
    if (alarmSounds.count > 0) {
        [self updateTableWithSounds:alarmSounds];
        return;
    }
    if ([self isLoading])
        return;
    self.navigationItem.rightBarButtonItem = nil;
    self.loading = YES;
    __weak typeof(self) weakSelf = self;
    [SENAPIAlarms availableSoundsWithCompletion:^(NSArray* sounds, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            alarmSounds = sounds;
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

- (NSInteger)selectedSoundIndex
{
    for (int index = 0; index < self.possibleSleepSounds.count; index++) {
        SENSound* sound = self.possibleSleepSounds[index];
        if ([sound.displayName isEqualToString:self.alarmCache.soundName]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)selectSoundAtIndex:(NSInteger)index
{
    if (index >= self.possibleSleepSounds.count)
        return;
    SENSound* sound = [self.possibleSleepSounds objectAtIndex:index];
    self.alarmCache.soundName = sound.displayName;
    self.alarmCache.soundID = sound.identifier;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger previousSelectionIndex = [self selectedSoundIndex];
    if (indexPath.row == previousSelectionIndex)
        return;

    [self selectSoundAtIndex:indexPath.row];
    self.loadingIndexPath = indexPath;
    [tableView reloadData];
    [self playAudioForSelectedSound];
}

#pragma mark - Audio

- (void)playAudioForSelectedSound
{
    [self stopAudio];
    [self.loadingQueue cancelAllOperations];
    SENSound* sound = self.possibleSleepSounds[[self selectedSoundIndex]];
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
    self.loadingIndexPath = nil;
    [self.tableView reloadData];
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
