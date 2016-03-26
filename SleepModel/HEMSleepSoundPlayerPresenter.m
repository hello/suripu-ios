//
//  HEMSleepSoundPlayerPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepSounds.h>
#import <SenseKit/SENSleepSoundDurations.h>

#import "HEMSleepSoundPlayerPresenter.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSoundConfigurationCell.h"
#import "HEMSleepSoundService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMStyle.h"

static CGFloat const HEMSleepSoundConfigCellHeight = 217.0f;

typedef NS_ENUM(NSInteger, HEMSleepSoundPlayerState) {
    HEMSleepSoundPlayerStateStopped = 0,
    HEMSleepSoundPlayerStatePlaying,
    HEMSleepSoundPlayerStateWaiting
};

@interface HEMSleepSoundPlayerPresenter() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) HEMSleepSoundService* service;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UIButton* actionButton;
@property (nonatomic, strong) SENSleepSounds* cachedSounds;
@property (nonatomic, strong) SENSleepSounds* availableSounds;
@property (nonatomic, strong) SENSleepSoundDurations* availableDurations;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, strong) SENSleepSound* selectedSound;
@property (nonatomic, strong) SENSleepSoundDuration* selectedDuration;

// TODO: remove once we hook everything up.  We should check status upon load
@property (nonatomic, assign) HEMSleepSoundPlayerState playerState;

@end

@implementation HEMSleepSoundPlayerPresenter

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)service
                           andSleepSounds:(nullable SENSleepSounds*)sleepSounds {
    self = [super init];
    if (self) {
        _service = service;
        _cachedSounds = sleepSounds;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout* layout = (id)[collectionView collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    itemSize.height = HEMSleepSoundConfigCellHeight;
    [layout setItemSize:itemSize];
    
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithActionButton:(UIButton*)button {
    // TODO: do not auto default to button image.  need to check status
    [button addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    
    CGFloat buttonWidth = CGRectGetWidth([button bounds]);
    [[button layer] setCornerRadius:buttonWidth / 2.0f];
    
    [self setActionButton:button];
    [self setPlayerState:HEMSleepSoundPlayerStateStopped];
}

- (void)loadSleepSounds:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [[self service] availableSleepSounds:^(id  _Nullable data, NSError * _Nullable error) {
        if ([data isKindOfClass:[SENSleepSounds class]]) {
            [weakSelf setAvailableSounds:data];
        }
        completion();
    }];
}

- (void)loadSleepSoundDurations: (void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [[self service] availableDurations:^(id  _Nullable data, NSError * _Nullable error) {
        if ([data isKindOfClass:[SENSleepSoundDurations class]]) {
            [weakSelf setAvailableDurations:data];
        }
        completion();
    }];
}

- (void)loadData {
    if ([self isLoading]) {
        return;
    }
    
    [self setLoading:YES];
    
    dispatch_group_t dataGroup = dispatch_group_create();
    
    // might have been provided to the presenter already
    if (![self cachedSounds]) {
        dispatch_group_enter(dataGroup);
        [self loadSleepSounds:^{
            dispatch_group_leave(dataGroup);
        }];
    } else {
        [self setAvailableSounds:[self cachedSounds]];
        [self setCachedSounds:nil]; // remove the cache
    }
    
    dispatch_group_enter(dataGroup);
    [self loadSleepSoundDurations:^{
        dispatch_group_leave(dataGroup);
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        HEMSleepSoundService* service = [strongSelf service];
        if (![strongSelf selectedSound]) {
            [strongSelf setSelectedSound:[service defaultSleepSoundFrom:[strongSelf availableSounds]]];
        }
        if (![strongSelf selectedDuration]) {
            [strongSelf setSelectedDuration:[service defaultDurationFrom:[strongSelf availableDurations]]];
        }
        [[strongSelf collectionView] reloadData];
        [strongSelf setLoading:NO];
    });
}

- (void)setPlayerState:(HEMSleepSoundPlayerState)playerState {
    _playerState = playerState;
    [[self actionButton] setEnabled:YES];
    [[self indicatorView] stop];
    [[self indicatorView] removeFromSuperview];
    
    switch (playerState) {
        case HEMSleepSoundPlayerStateStopped:
            [[self actionButton] setImage:[UIImage imageNamed:@"sleepSoundPlayIcon"]
                                 forState:UIControlStateNormal];
            break;
        case HEMSleepSoundPlayerStatePlaying:
            [[self actionButton] setImage:[UIImage imageNamed:@"sleepSoundStopIcon"]
                                 forState:UIControlStateNormal];
            break;
        default: {
            [[self actionButton] setEnabled:NO];
            
            if (![self indicatorView]) {
                CGSize buttonSize = [[self actionButton] bounds].size;
                UIImage* indicatorImage = [UIImage imageNamed:@"loaderWhite"];
                CGRect indicatorFrame = CGRectZero;
                indicatorFrame.size = indicatorImage.size;
                indicatorFrame.origin.x = (buttonSize.width - indicatorImage.size.width) / 2.f;
                indicatorFrame.origin.y = (buttonSize.height - indicatorImage.size.height) / 2.f;
                HEMActivityIndicatorView* indicator =
                    [[HEMActivityIndicatorView alloc] initWithImage:indicatorImage
                                                           andFrame:indicatorFrame];
                [self setIndicatorView:indicator];
            }

            [[self indicatorView] start];
            [[self actionButton] setImage:nil forState:UIControlStateNormal];
            [[self actionButton] addSubview:[self indicatorView]];
            break;
        }
    }
}

- (void)setSelectedSound:(SENSleepSound*)sound {
    BOOL shouldReload = _selectedSound != nil;
    if (![[_selectedSound identifier] isEqualToNumber:[sound identifier]]) {
        _selectedSound = sound;
        if (shouldReload) {
            [[self collectionView] reloadData];
        }
    }
}

- (void)setSelectedDuration:(SENSleepSoundDuration*)duration {
    BOOL shouldReload = _selectedDuration != nil;
    if (![[_selectedDuration identifier] isEqualToNumber:[duration identifier]]) {
        _selectedDuration = duration;
        if (shouldReload) {
            [[self collectionView] reloadData];
        }
    }
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    [self loadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // only ever return 1 configuration cell.  it's a collection view for extensibility
    // and to inherit card layout attributes and others
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard settingsReuseIdentifier]
                                                     forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate

- (void)configureSleepSoundConfigurationCell:(HEMSleepSoundConfigurationCell*)cell {
    [[cell titleLabel] setTextColor:[UIColor sleepSoundPlayerTitleColor]];
    [[cell soundLabel] setTextColor:[UIColor sleepSoundPlayerTitleColor]];
    [[cell soundValueLabel] setText:[[self selectedSound] localizedName]];
    [[cell soundValueLabel] setTextColor:[UIColor sleepSoundPlayerOptionValueColor]];
    [[cell soundSelectorButton] addTarget:self
                                   action:@selector(changeSound:)
                         forControlEvents:UIControlEventTouchUpInside];
    [[cell durationLabel] setTextColor:[UIColor sleepSoundPlayerTitleColor]];
    [[cell durationValueLabel] setText:[[self selectedDuration] localizedName]];
    [[cell durationValueLabel] setTextColor:[UIColor sleepSoundPlayerOptionValueColor]];
    [[cell durationSelectorButton] addTarget:self
                                      action:@selector(changeDuration:)
                            forControlEvents:UIControlEventTouchUpInside];
    [[cell volumeLabel] setTextColor:[UIColor sleepSoundPlayerTitleColor]];
    [[cell volumeValueLabel] setText:NSLocalizedString(@"sleep-sounds.volume.high", nil)];
    [[cell volumeValueLabel] setTextColor:[UIColor sleepSoundPlayerOptionValueColor]];
    [[cell volumeSelectorButton] addTarget:self
                                    action:@selector(changeVolume:)
                          forControlEvents:UIControlEventTouchUpInside];
    [[cell volumeAccessoryView] setHidden:YES];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSleepSoundConfigurationCell class]]) {
        [self configureSleepSoundConfigurationCell:(id)cell];
    }
}

#pragma mark - Player Actions

- (void)changeSound:(UIButton*)button {
    DDLogVerbose(@"change sound");
    [[self delegate] showAvailableSounds:[[self availableSounds] sounds]
                       selectedSoundName:[[self selectedSound] localizedName]
                               withTitle:NSLocalizedString(@"sleep-sounds.option.title.sound", nil)
                                subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.sound", nil)
                                    from:self];
}

- (void)changeDuration:(UIButton*)button {
    DDLogVerbose(@"change duration");
    [[self delegate] showAvailableDurations:[[self availableDurations] durations]
                       selectedDurationName:[[self selectedDuration] localizedName]
                                  withTitle:NSLocalizedString(@"sleep-sounds.option.title.duration", nil)
                                   subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.duration", nil)
                                       from:self];
}

- (void)changeVolume:(UIButton*)button {
    DDLogVerbose(@"change volume");
}

- (void)takeAction:(UIButton*)button {
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStateStopped:
            [self play:button];
            break;
        case HEMSleepSoundPlayerStatePlaying:
            [self stop:button];
            break;
        default:
            break;
    }
}

- (void)play:(UIButton*)button {
    DDLogVerbose(@"attempting to play sound");
    [self setPlayerState:HEMSleepSoundPlayerStateWaiting];
    
    __weak typeof(self) weakSelf = self;
    [[self service] playSound:[self selectedSound]
                  forDuration:[self selectedDuration]
                   withVolume:80
                   completion:^(NSError * _Nullable error) {
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                       if (!error) {
                           DDLogVerbose(@"playing sound");
                           [strongSelf setPlayerState:HEMSleepSoundPlayerStatePlaying];
                       } else {
                           DDLogVerbose(@"failed to play sound");
                           [strongSelf setPlayerState:HEMSleepSoundPlayerStateStopped];
                           [[strongSelf delegate] presentError:error];
                       }
                       
                   }];
}

- (void)stop:(UIButton*)button {
    DDLogVerbose(@"attempting to stop sound");
    [self setPlayerState:HEMSleepSoundPlayerStateWaiting];
    
    __weak typeof(self) weakSelf = self;
    [[self service] stopPlaying:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (!error) {
            DDLogVerbose(@"stopped sound");
            [strongSelf setPlayerState:HEMSleepSoundPlayerStateStopped];
        } else {
            DDLogVerbose(@"failed to stop sound");
            [strongSelf setPlayerState:HEMSleepSoundPlayerStatePlaying];
            [[strongSelf delegate] presentError:error];
        }
    }];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
