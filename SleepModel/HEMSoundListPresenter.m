//
//  HEMSoundListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 4/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "AVAudioPlayer+HEMVolumeControl.h"

#import "HEMSoundListPresenter.h"
#import "HEMAudioService.h"
#import "HEMAudioButton.h"
#import "HEMListItemCell.h"

static CGFloat const HEMSoundPreviewFadeInterval = 5.0f;

@interface HEMSoundListPresenter()

@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, weak) HEMAudioService* audioService;
@property (nonatomic, assign) BOOL loadingSound;

@end

@implementation HEMSoundListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService {
    self = [super initWithTitle:title items:items selectedItemNames:@[selectedItemName]];
    if (self) {
        _audioService = audioService;
    }
    return self;
}

#pragma mark - Presenter states

- (void)willDisappear {
    [super willDisappear];
    [self stop];
}

- (void)didEnterBackground {
    [super didEnterBackground];
    [self stop];
}

#pragma mark - Subclass methods

- (NSString*)selectedPreviewUrl {
    return nil;
}

- (BOOL)item:(id)item matchesCurrentPreviewUrl:(NSString*)currentUrl {
    return NO;
}

- (void)updateCell:(UITableViewCell *)cell withItem:(id)item selected:(BOOL)selected {
    [super updateCell:cell withItem:item selected:selected];
    NSString* prevSelectedUrl = [self selectedPreviewUrl];
    BOOL prevSelected = [self item:item matchesCurrentPreviewUrl:prevSelectedUrl];
    
    if (selected && !prevSelected) {
        [self clearAudio];
    }
    
    HEMAudioButton* button = (id) [cell accessoryView];
    [button setHidden:!selected];
    [button setAudioState:[self stateBasedOnPlayer]];
}

#pragma mark - Audio Buttons

- (HEMAudioButton*)selectedAudioButton {
    HEMAudioButton* button = nil;
    NSIndexPath* path = [[self tableView] indexPathForSelectedRow];
    if (path) {
        UITableViewCell* cell = [[self tableView] cellForRowAtIndexPath:path];
        button = (id) [cell accessoryView];
    }
    return button;
}

- (void)clearAudio {
    [[self audioPlayer] stop];
    [self setAudioPlayer:nil];
}

- (HEMAudioButtonState)stateBasedOnPlayer {
    HEMAudioButtonState state = HEMAudioButtonStateStopped;
    if ([[self audioPlayer] isPlaying]) {
        state = HEMAudioButtonStatePlaying;
    }
    return state;
}

- (HEMAudioButton*)newAudioButton {
    HEMAudioButton* button = [HEMAudioButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(toggleAudio:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setAudioState:HEMAudioButtonStateStopped];
    return button;
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString* selectedUrl = [self selectedPreviewUrl];
    BOOL selected = [self item:item matchesCurrentPreviewUrl:selectedUrl];
    if (![cell accessoryView]) {
        HEMAudioButton* audioButton = [self newAudioButton];
        [audioButton setAudioState:[self stateBasedOnPlayer]];
        [cell setAccessoryView:audioButton];
    }
    [[cell accessoryView] setHidden:!selected];
}

#pragma mark - Audio Notifications

- (void)listenForAudioNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(stop)
                   name:AVAudioSessionInterruptionNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(stop)
                   name:AVAudioSessionMediaServicesWereLostNotification
                 object:nil];
    
}

- (void)stopListeningForAudioNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [center removeObserver:self name:AVAudioSessionMediaServicesWereLostNotification object:nil];
}

#pragma mark - Audio Actions

- (void)toggleAudio:(HEMAudioButton*)audioButton {
    if ([audioButton audioState] == HEMAudioButtonStatePlaying) {
        [self stop];
    } else {
        [self play];
    }
}

- (void)play {
    __weak typeof(self) weakSelf = self;
    [[self audioService] activateSession:YES completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // ignore the error, play anyways and see
        if ([strongSelf audioPlayer]) {
            [strongSelf replay];
        } else {
            [strongSelf loadSelectedAudioFileAndPlay];
        }
    }];
}

- (void)loadSelectedAudioFileAndPlay {
    [self stop];
    
    if (![self selectedPreviewUrl]) {
        return;
    }
    
    HEMAudioButton* selectedAudioButton = [self selectedAudioButton];
    [selectedAudioButton setAudioState:HEMAudioButtonStateLoading];
    
    __block NSString* selectedPreviewUrl = [[self selectedPreviewUrl] copy];
    __weak typeof(self) weakSelf = self;
    
    void(^finish)(NSData* data, NSError* error) = ^(NSData* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && data) {
            // check if sound id is still the same as currently selected sound id
            NSString* currentSelectionUrl = [strongSelf selectedPreviewUrl];
            if (![currentSelectionUrl isEqualToString:selectedPreviewUrl]) {
                return; // skip
            }
            
            NSError* error = nil;
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            
            HEMAudioButton* selectedAudioButton = [strongSelf selectedAudioButton];
            
            if (error) {
                [SENAnalytics trackError:error];
                [selectedAudioButton setAudioState:HEMAudioButtonStateStopped];
            } else if ([player playWithVolumeFadeOver:HEMSoundPreviewFadeInterval]) {
                [player setNumberOfLoops:-1]; // indefinitely
                [selectedAudioButton setAudioState:HEMAudioButtonStatePlaying];
                [strongSelf setAudioPlayer:player];
                [strongSelf listenForAudioNotifications];
            } else {
                [selectedAudioButton setAudioState:HEMAudioButtonStateStopped];
            }
        } else {
            [selectedAudioButton setAudioState:HEMAudioButtonStateStopped];
        }
    };
    [[self audioService] downloadAudioFileWithURL:selectedPreviewUrl
                                       completion:finish];
    
}

- (void)stop {
    [[self audioPlayer] stop];
    [[self audioPlayer] setCurrentTime:0.0f];
    [[self selectedAudioButton] setAudioState:HEMAudioButtonStateStopped];
    [self stopListeningForAudioNotifications];
}

- (void)replay {
    [[self audioPlayer] playWithVolumeFadeOver:HEMSoundPreviewFadeInterval];
    [[self selectedAudioButton] setAudioState:HEMAudioButtonStatePlaying];
    [self listenForAudioNotifications];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
}

@end
