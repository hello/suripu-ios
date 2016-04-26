//
//  HEMSoundListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 4/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "HEMSoundListPresenter.h"
#import "HEMAudioService.h"
#import "HEMAudioButton.h"
#import "HEMListItemCell.h"

@interface HEMSoundListPresenter()

@property (nonatomic, strong) HEMAudioButton* audioButton; // only one can be seen
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, weak) HEMAudioService* audioService;
@property (nonatomic, assign) BOOL loadingSound;

@end

@implementation HEMSoundListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService {
    self = [super initWithTitle:title items:items selectedItemName:selectedItemName];
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

#pragma mark - Audio Buttons

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
    
    NSString* selectedUrl = [self selectedPreviewUrl];
    BOOL selected = [self item:item matchesCurrentPreviewUrl:selectedUrl];
    
    [self updateAudioButtonStateForCell:cell selected:selected forItem:item];
}

- (void)cell:(HEMListItemCell *)cell isSelected:(BOOL)selected forItem:(id)item {
    [super cell:cell isSelected:selected forItem:item];
    
    NSString* prevSelectedUrl = [self selectedPreviewUrl];
    BOOL prevSelected = [self item:item matchesCurrentPreviewUrl:prevSelectedUrl];
    
    if (selected && !prevSelected) {
        [self clearAudio];
    }
    
    [self updateAudioButtonStateForCell:cell selected:selected forItem:item];
}

- (void)updateAudioButtonStateForCell:(HEMListItemCell*)cell
                             selected:(BOOL)selected forItem:(id)item {
    if ([self selectedPreviewUrl] > 0 && selected) {
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
    
    __block NSString* selectedPreviewUrl = [[self selectedPreviewUrl] copy];
    [[self audioButton] setAudioState:HEMAudioButtonStateLoading];
    
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
    [[self audioService] downloadAudioFileWithURL:selectedPreviewUrl
                                       completion:finish];
    
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

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_audioPlayer) {
        [_audioPlayer stop];
    }
}

@end
