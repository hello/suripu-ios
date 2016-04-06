//
//  HEMSleepSoundsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import <SenseKit/SENSleepSounds.h>

#import "HEMSleepSoundsPresenter.h"
#import "HEMListItemCell.h"
#import "HEMAudioButton.h"
#import "HEMAudioService.h"
#import "HEMStyle.h"

@interface HEMSleepSoundsPresenter()

@property (nonatomic, strong) HEMAudioButton* audioButton; // only one can be seen
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, assign) BOOL loadingSound;
@property (nonatomic, weak) HEMAudioService* audioService;
@property (nonatomic, weak) SENSleepSound* selectedSound;

@end

@implementation HEMSleepSoundsPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService {
    self = [super initWithTitle:title items:items selectedItemName:selectedItemName];
    if (self) {
        _audioService = audioService;
        [self configureSelectedSound];
    }
    return self;
}

- (void)configureSelectedSound {
    for (SENSleepSound* sound in [self items]) {
        if ([[sound localizedName] isEqualToString:[self selectedItemName]]) {
            [self setSelectedSound:sound];
            break;
        }
    }
}

#pragma mark - Presenter states

- (void)didDisappear {
    [super didDisappear];
    if ([self audioPlayer]) {
        [[self audioPlayer] stop];
    }
}

#pragma mark -

- (HEMAudioButtonState)stateBasedOnPlayer {
    HEMAudioButtonState state = HEMAudioButtonStateStopped;
    if ([[self audioPlayer] isPlaying]) {
        state = HEMAudioButtonStatePlaying;
    }
    return state;
}

- (HEMAudioButton*)audioButtonWithSize:(CGSize)size {
    if (![self audioButton]) {
        HEMAudioButton* button = [HEMAudioButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self
                   action:@selector(toggleAudio:)
         forControlEvents:UIControlEventTouchUpInside];
        [self setAudioButton:button];
    }
    
    CGRect buttonFrame = CGRectZero;
    buttonFrame.size = size;
    [[self audioButton] setFrame:buttonFrame];
    [[self audioButton] setAudioState:HEMAudioButtonStateStopped];
    return [self audioButton];
}

- (void)configureCell:(HEMListItemCell *)cell forItem:(id)item {
    [super configureCell:cell forItem:item];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    SENSleepSound* sound = item;
    [[cell itemLabel] setText:[sound localizedName]];
    
    NSNumber* selectedSoundId = [[self selectedSound] identifier];
    BOOL selected = [selectedSoundId isEqualToNumber:[sound identifier]];
    [cell setSelected:selected];
    
    [self updateAudioButtonStateForCell:cell selected:selected forItem:sound];
}

- (void)updateAudioButtonStateForCell:(HEMListItemCell*)cell selected:(BOOL)selected forItem:(id)item {
    SENSleepSound* sound = item;
    if ([[sound previewURL] length] > 0 && selected) {
        CGFloat cellHeight = CGRectGetHeight([cell bounds]);
        CGSize size = CGSizeMake(cellHeight, cellHeight);
        HEMAudioButton* audioButton = [self audioButtonWithSize:size];
        [audioButton setAudioState:[self stateBasedOnPlayer]];
        [cell setAccessoryView:audioButton];
    } else {
        [[self audioButton] removeFromSuperview];
        [cell setAccessoryView:nil];
    }
}

- (void)cell:(HEMListItemCell *)cell isSelected:(BOOL)selected forItem:(id)item {
    [super cell:cell isSelected:selected forItem:item];

    SENSleepSound* sound = item;
    
    NSNumber* selectedSoundId = [[self selectedSound] identifier];
    if (selected && ![selectedSoundId isEqualToNumber:[sound identifier]]) {
        [self setAudioPlayer:nil];
        [self setSelectedSound:sound];
    }
    
    [self updateAudioButtonStateForCell:cell selected:selected forItem:item];
}

#pragma mark - Audio Button Actions

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

- (void)stop {
    [[self audioPlayer] stop];
    [[self audioPlayer] setCurrentTime:0.0f];
    [[self audioButton] setAudioState:HEMAudioButtonStateStopped];
    [self stopListeningForAudioNotifications];
}

- (void)replay {
    [[self audioPlayer] setVolume:1.0f];
    [[self audioPlayer] play];
    [[self audioButton] setAudioState:HEMAudioButtonStatePlaying];
    [self listenForAudioNotifications];
}

- (void)loadSelectedAudioFileAndPlay {
    [self stop];
    
    if (![self selectedSound]) {
        return;
    }
    
    [[self audioButton] setAudioState:HEMAudioButtonStateLoading];
    
    __weak typeof(self) weakSelf = self;
    void(^finish)(NSData* data, NSError* error) = ^(NSData* data, NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && data) {
            NSError* error = nil;
            AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithData:data error:&error];
            if (error) {
                [SENAnalytics trackError:error];
                [[strongSelf audioButton] setAudioState:HEMAudioButtonStateStopped];
            } else if ([player play]) {
                [player setVolume:1.0f];
                [player setNumberOfLoops:-1]; // indefinitely
                [[strongSelf audioButton] setAudioState:HEMAudioButtonStatePlaying];
                [strongSelf setAudioPlayer:player];
                [strongSelf listenForAudioNotifications];
            } else {
                [[strongSelf audioButton] setAudioState:HEMAudioButtonStateStopped];
            }
        } else {
            [[strongSelf audioButton] setAudioState:HEMAudioButtonStateStopped];
        }
    };
    [[self audioService] downloadAudioFileWithURL:[[self selectedSound] previewURL] completion:finish];
    
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

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
}

@end
