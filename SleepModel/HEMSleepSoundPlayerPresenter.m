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
@property (nonatomic, strong) SENSleepSounds* availableSounds;
@property (nonatomic, strong) SENSleepSoundDurations* availableDurations;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) HEMActivityIndicatorView* indicatorView;

// TODO: remove once we hook everything up.  We should check status upon load
@property (nonatomic, assign) HEMSleepSoundPlayerState playerState;

@end

@implementation HEMSleepSoundPlayerPresenter

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)service {
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout* layout = (id)[collectionView collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    itemSize.height = HEMSleepSoundConfigCellHeight;
    [layout setItemSize:itemSize];
    
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
    
    dispatch_group_enter(dataGroup);
    [self loadSleepSounds:^{
        dispatch_group_leave(dataGroup);
    }];
    
    dispatch_group_enter(dataGroup);
    [self loadSleepSoundDurations:^{
        dispatch_group_leave(dataGroup);
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        [[weakSelf collectionView] reloadData];
        [weakSelf setLoading:NO];
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
    SENSleepSound* defaultSound = [[self service] defaultSleepSoundFrom:[self availableSounds]];
    SENSleepSoundDuration* defaultDuration = [[self service] defaultDurationFrom:[self availableDurations]];
    [[cell soundValueLabel] setText:[defaultSound localizedName]];
    [[cell durationValueLabel] setText:[defaultDuration localizedName]];
    [[cell volumeValueLabel] setText:NSLocalizedString(@"sleep-sounds.volume.high", nil)];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSleepSoundConfigurationCell class]]) {
        [self configureSleepSoundConfigurationCell:(id)cell];
    }
}

#pragma mark - Player Actions

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
    
    SENSleepSound* sound = [[self service] defaultSleepSoundFrom:[self availableSounds]];
    SENSleepSoundDuration* duration = [[self service] defaultDurationFrom:[self availableDurations]];
    
    __weak typeof(self) weakSelf = self;
    [[self service] playSound:sound forDuration:duration withVolume:100 completion:^(NSError * _Nullable error) {
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
