
#import <AVFoundation/AVFoundation.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENSound.h>
#import <SpinKit/RTSpinKitView.h>

#import "HEMAlarmSoundTableViewController.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "HEMAlarmPropertyTableViewCell.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMAlarmCache.h"
#import "HEMAlertViewController.h"

@interface HEMAlarmSoundTableViewController () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSArray *possibleSleepSounds;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic, strong) NSOperationQueue *loadingQueue;
@property (nonatomic, strong) NSIndexPath *loadingIndexPath;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lineViewHeightConstraint;
@property (nonatomic, weak) IBOutlet UINavigationItem* customNavItem;
@end

@implementation HEMAlarmSoundTableViewController

static NSString *const HEMAlarmSoundFormat = @"m4a";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loadingQueue = [NSOperationQueue new];
    self.loadingQueue.maxConcurrentOperationCount = 1;
    self.lineViewHeightConstraint.constant = 0.5;
    [self configureAudioSession];
    [self loadAlarmSounds];
    [[self tableView] setTableFooterView:[[UIView alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopAudio];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureAudioSession {
    NSError* audioSessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                           error:&audioSessionError];
    
    if (audioSessionError) {
        [SENAnalytics trackError:audioSessionError withEventName:kHEMAnalyticsEventError];
    }
}

- (void)loadAlarmSounds {
    [self loadAlarmSoundsWithRetryCount:3];
}

- (void)loadAlarmSoundsWithRetryCount:(NSInteger)count {
    static NSArray *alarmSounds = nil;
    if (alarmSounds.count > 0) {
        [self updateTableWithSounds:alarmSounds];
        return;
    }
    if ([self isLoading])
        return;
    UIActivityIndicatorView *indicatorView =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.customNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    [indicatorView startAnimating];
    self.loading = YES;
    __weak typeof(self) weakSelf = self;
    __weak UIActivityIndicatorView *weakIndicator = indicatorView;
    [SENAPIAlarms availableSoundsWithCompletion:^(NSArray *sounds, NSError *error) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      [weakIndicator stopAnimating];
      strongSelf.customNavItem.rightBarButtonItem = nil;
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

- (void)updateTableWithSounds:(NSArray *)sounds {
    self.possibleSleepSounds = [sounds sortedArrayUsingComparator:^NSComparisonResult(SENSound *obj1, SENSound *obj2) {
      return [obj1.displayName compare:obj2.displayName];
    }];
    [self.tableView reloadData];
}

- (void)showAlertForError:(NSError *)error {
    DDLogError(@"Failed to load alarm sounds: %@", error.localizedDescription);
    [HEMAlertViewController showInfoDialogWithTitle:NSLocalizedString(@"alarm.sounds.error.title", nil)
                                            message:NSLocalizedString(@"alarm.sounds.error.message", nil)
                                         controller:self];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                 target:self
                                                                                 action:@selector(loadAlarmSounds)];
    refreshItem.tintColor = [UIColor tintColor];
    self.customNavItem.rightBarButtonItem = refreshItem;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.possibleSleepSounds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [HEMMainStoryboard alarmChoiceCellReuseIdentifier];
    HEMAlarmPropertyTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    SENSound *sound = [self.possibleSleepSounds objectAtIndex:indexPath.row];
    BOOL isSelected = [sound.displayName isEqualToString:self.alarmCache.soundName];
    BOOL isLoading = [self.loadingIndexPath isEqual:indexPath];
    cell.titleLabel.text = sound.displayName;
    cell.disclosureImageView.hidden = !isSelected;
    cell.titleLabel.textColor = isSelected ? [UIColor alarmSelectionRowColor]
                                           : [UIColor backViewNavTitleColor];
    if (isLoading) {
        [cell.loadingIndicatorView startAnimating];
    } else { [cell.loadingIndicatorView stopAnimating]; }
    if (isSelected && !isLoading) {
        UIImage *image = [self.player isPlaying] ? [HelloStyleKit miniStopButton] : [HelloStyleKit miniPlayButton];
        [cell.playStopButton setImage:image forState:UIControlStateNormal];
        cell.playStopButton.hidden = NO;
    } else { cell.playStopButton.hidden = YES; }
    return cell;
}

#pragma mark - Table view delegate

- (NSInteger)selectedSoundIndex {
    for (int index = 0; index < self.possibleSleepSounds.count; index++) {
        SENSound *sound = self.possibleSleepSounds[index];
        if ([sound.displayName isEqualToString:self.alarmCache.soundName]) {
            return index;
        }
    }
    return NSNotFound;
}

- (void)selectSoundAtIndex:(NSInteger)index {
    if (index >= self.possibleSleepSounds.count)
        return;
    SENSound *sound = [self.possibleSleepSounds objectAtIndex:index];
    self.alarmCache.soundName = sound.displayName;
    self.alarmCache.soundID = sound.identifier;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (IBAction)toggleAudio:(UIButton *)sender {
    if ([self.player isPlaying]) {
        [self stopAudio];
    } else { [self playAudio]; }
}

- (void)playAudioForSelectedSound {
    [self stopAudio];
    [self.loadingQueue cancelAllOperations];
    SENSound *sound = self.possibleSleepSounds[[self selectedSoundIndex]];
    NSURL *url = [NSURL URLWithString:sound.URLPath];

    __weak typeof(self) weakSelf = self;
    [self.loadingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
      __strong typeof(weakSelf) strongSelf = weakSelf;
      NSData *urlData = [NSData dataWithContentsOfURL:url];
      if (!urlData) {
          [[NSOperationQueue mainQueue]
              addOperation:[NSBlockOperation blockOperationWithBlock:^{ [strongSelf stopLoadingAnimation]; }]];
          return;
      }

      [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
        [strongSelf stopLoadingAnimation];
        NSError *error = nil;
        strongSelf.player = [[AVAudioPlayer alloc] initWithData:urlData error:&error];
        strongSelf.player.delegate = self;
        strongSelf.player.volume = 1.f;
        if (error)
            [strongSelf stopAudio];
        else {
            [strongSelf playAudio];
        }
      }]];
    }]];
}

/**
 * Activate / deactivate audio session.  This needs to happen on a background
 * thread because setActivate:withOptions:error is a blocking call that can
 * potentially take a little bit of time.
 *
 * @param activate: YES to activate, NO otherwise
 */
- (void)activateAudioSession:(BOOL)activate completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSError *error = nil;
        AVAudioSessionSetActiveOptions options
            = activate
            ? 0
            : AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation;
        
        // need to make sure player is stopped when deactivating or else it can
        // cause an exception to be raised
        if (!activate && [[strongSelf player] isPlaying]) {
            [[strongSelf player] stop];
        }
        
        [[AVAudioSession sharedInstance] setActive:activate
                                       withOptions:options
                                             error:&error];
        if (error) {
            DDLogWarn(@"failed to change audio session state");
            [SENAnalytics trackError:error withEventName:kHEMAnalyticsEventError];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (error);
            });
        }
    });
}

- (void)playAudio {
    __weak typeof(self) weakSelf = self;
    [self activateAudioSession:YES completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf.player) {
            strongSelf.player.volume = 1.0f;
            [strongSelf.player play];
            [strongSelf updatePlayButtonWithImage:[HelloStyleKit miniStopButton]];
        } else {
            strongSelf.loadingIndexPath = [NSIndexPath indexPathForRow:[strongSelf selectedSoundIndex]
                                                             inSection:0];
            [strongSelf.tableView reloadData];
            [strongSelf playAudioForSelectedSound];
        }
    }];
}

- (void)stopAudio {
    [self.player stop];
    self.player.currentTime = 0;
    [self updatePlayButtonWithImage:[HelloStyleKit miniPlayButton]];
    [self activateAudioSession:NO completion:nil];
}

- (void)updatePlayButtonWithImage:(UIImage *)image {
    NSInteger selectedIndex = [self selectedSoundIndex];
    if (selectedIndex == NSNotFound || selectedIndex >= [self.tableView numberOfRowsInSection:0])
        return;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    HEMAlarmPropertyTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.playStopButton setImage:image forState:UIControlStateNormal];
}

- (void)stopLoadingAnimation {
    self.loadingIndexPath = nil;
    [self.tableView reloadData];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self stopAudio];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopAudio];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [self stopAudio];
}

@end
