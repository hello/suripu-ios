//
//  HEMSleepSoundPlayerPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENSleepSounds.h>
#import <SenseKit/SENSleepSoundDurations.h>
#import <SenseKit/SENSleepSoundStatus.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENPairedDevices.h>

#import "NSString+HEMUtils.h"

#import "HEMSleepSoundPlayerPresenter.h"
#import "HEMMainStoryboard.h"
#import "HEMSleepSoundConfigurationCell.h"
#import "HEMIntroMessageCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMSleepSoundService.h"
#import "HEMDeviceService.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSleepSoundVolume.h"
#import "HEMStyle.h"

static CGFloat const HEMSleepSoundConfigCellHeight = 217.0f;

typedef NS_ENUM(NSInteger, HEMSleepSoundPlayerState) {
    HEMSleepSoundPlayerStatePrereqNotMet = 0,
    HEMSleepSoundPlayerStateStopped,
    HEMSleepSoundPlayerStatePlaying,
    HEMSleepSoundPlayerStateWaiting,
    HEMSleepSoundPlayerStateSenseOffline,
    HEMSleepSoundPlayerStateError
};

@interface HEMSleepSoundPlayerPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMSleepSoundService* service;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UIButton* actionButton;
@property (nonatomic, strong) SENSleepSounds* cachedSounds;
@property (nonatomic, strong) SENSleepSounds* availableSounds;
@property (nonatomic, strong) SENSleepSoundDurations* availableDurations;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, strong) SENSleepSound* selectedSound;
@property (nonatomic, strong) SENSleepSoundDuration* selectedDuration;
@property (nonatomic, strong) HEMSleepSoundVolume* selectedVolume;
@property (nonatomic, assign) HEMSleepSoundPlayerState playerState;
@property (nonatomic, weak) HEMSleepSoundConfigurationCell* configCell;
@property (nonatomic, assign, getter=isWaitingForOptionChange) BOOL waitingForOptionChange;
@property (nonatomic, assign, getter=isSenseOffline) BOOL senseOffline;

@end

@implementation HEMSleepSoundPlayerPresenter

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService *)service
                            deviceService:(HEMDeviceService*)deviceService {
    self = [super init];
    if (self) {
        _service = service;
        _deviceService = deviceService;
        _playerState = HEMSleepSoundPlayerStateWaiting;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithActionButton:(UIButton*)button {
    CGFloat buttonWidth = CGRectGetWidth([button bounds]);
    [[button layer] setCornerRadius:buttonWidth / 2.0f];
    [button addTarget:self action:@selector(takeAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    [button setImage:nil forState:UIControlStateNormal];
    
    NSShadow* shadow = [NSShadow shadowForCircleActionButton];
    [[button layer] setShadowRadius:[shadow shadowBlurRadius]];
    [[button layer] setShadowOffset:[shadow shadowOffset]];
    [[button layer] setShadowColor:[[shadow shadowColor] CGColor]];
    [[button layer] setShadowOpacity:0.85f];
    
    [self setActionButton:button];
    [self setIndicatorView:[self activityIndicator]];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    if (![self isWaitingForOptionChange]) {
        [SENAnalytics track:HEMAnalyticsEventSleepSoundView];
        [self loadData];
    }
    [self setWaitingForOptionChange:NO];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self loadData];
}

#pragma mark -

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
    
    // we will assume HEMDeviceService has latest data so we do not have to make even more
    // API calls ... getting to be wayyy too many
    SENSenseMetadata* senseMetadata = [[[self deviceService] devices] senseMetadata];
    [self setSenseOffline:[[self service] isSenseLastSeenGoingToBeAProblem:[senseMetadata lastSeenDate]]];
    
    [self setLoading:YES];
    [self setPlayerState:HEMSleepSoundPlayerStateWaiting];
    
    dispatch_group_t dataGroup = dispatch_group_create();

    // might have been provided to the presenter already
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
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoading:NO];
        
        if ([strongSelf isSenseOffline]) {
            [strongSelf reloadDataWithPlayerState:HEMSleepSoundPlayerStateSenseOffline];
        } else if ([[[strongSelf availableSounds] sounds] count] == 0) {
            [strongSelf reloadDataWithPlayerState:HEMSleepSoundPlayerStatePrereqNotMet];
        } else {
            [strongSelf checkIfAlreadyPlaying];
        }
        
    });
}

- (void)checkIfAlreadyPlaying{
    [self setLoading:YES];
    
    __weak typeof(self) weakSelf = self;
    [[self service] checkCurrentSleepSoundStatus:^(id  _Nullable data, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            HEMSleepSoundService* service = [strongSelf service];
            SENSleepSoundStatus* status = data;
            
            if ([status isPlaying] && [status sound] && [status duration]) {
                [strongSelf setSelectedSound:[status sound]];
                [strongSelf setSelectedDuration:[status duration]];
                [strongSelf setSelectedVolume:[strongSelf volumeObjectForValue:[status volume]]];
                [strongSelf setPlayerState:HEMSleepSoundPlayerStatePlaying];
            } else {
                if (![strongSelf selectedSound]) {
                    [strongSelf setSelectedSound:[service defaultSleepSoundFrom:[strongSelf availableSounds]]];
                }
                if (![strongSelf selectedDuration]) {
                    [strongSelf setSelectedDuration:[service defaultDurationFrom:[strongSelf availableDurations]]];
                }
                [strongSelf setPlayerState:HEMSleepSoundPlayerStateStopped];
            }
            // volume is not returned in the status :(
            if (![strongSelf selectedVolume]) {
                [strongSelf setSelectedVolume:[service defaultVolume]];
            }
        } else {
            [strongSelf setPlayerState:HEMSleepSoundPlayerStateError];
        }
        
        [[strongSelf collectionView] reloadData];
        [strongSelf setLoading:NO];
        
    }];
}

- (void)reloadDataWithPlayerState:(HEMSleepSoundPlayerState)state {
    [self setPlayerState:state];
    [[self collectionView] reloadData];
}

- (void)setPlayerState:(HEMSleepSoundPlayerState)playerState {
    _playerState = playerState;

    [[[self configCell] titleLabel] setText:[self titleForPlayerState:[self playerState]]];
    [[self actionButton] setEnabled:YES];
    
    switch (playerState) {
        case HEMSleepSoundPlayerStateSenseOffline:
        case HEMSleepSoundPlayerStatePrereqNotMet:
            [[self actionButton] setHidden:YES];
            break;
        case HEMSleepSoundPlayerStateError:
            [[self configCell] deactivate:YES];
            [[self indicatorView] stop];
            [[self indicatorView] removeFromSuperview];
            [[self actionButton] setHidden:YES];
            break;
        case HEMSleepSoundPlayerStateStopped:
            [[self indicatorView] stop];
            [[self indicatorView] removeFromSuperview];
            [[self configCell] deactivate:NO];
            [[self actionButton] setHidden:NO];
            [[self actionButton] setImage:[UIImage imageNamed:@"sleepSoundPlayIcon"]
                                 forState:UIControlStateNormal];
            break;
        case HEMSleepSoundPlayerStatePlaying:
            [[self configCell] deactivate:YES];
            [[self indicatorView] stop];
            [[self indicatorView] removeFromSuperview];
            [[self actionButton] setHidden:NO];
            [[self actionButton] setImage:[UIImage imageNamed:@"sleepSoundStopIcon"]
                                 forState:UIControlStateNormal];
            break;
        default: {
            [[self configCell] deactivate:YES];
            [[self actionButton] setEnabled:NO];
            [[self indicatorView] start];
            [[self actionButton] setHidden:NO];
            [[self actionButton] setImage:nil forState:UIControlStateNormal];
            [[self actionButton] addSubview:[self indicatorView]];
            break;
        }
    }
}

- (HEMActivityIndicatorView*)activityIndicator {
    CGSize buttonSize = [[self actionButton] bounds].size;
    UIImage* indicatorImage = [UIImage imageNamed:@"loaderWhite"];
    CGRect indicatorFrame = CGRectZero;
    indicatorFrame.size = indicatorImage.size;
    indicatorFrame.origin.x = (buttonSize.width - indicatorImage.size.width) / 2.f;
    indicatorFrame.origin.y = (buttonSize.height - indicatorImage.size.height) / 2.f;
    return [[HEMActivityIndicatorView alloc] initWithImage:indicatorImage
                                                  andFrame:indicatorFrame];
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

- (void)setSelectedVolume:(HEMSleepSoundVolume *)selectedVolume {
    BOOL shouldReload = _selectedVolume != nil;
    if (![[_selectedVolume localizedName] isEqualToString:[selectedVolume localizedName]]) {
        _selectedVolume = selectedVolume;
        if (shouldReload) {
            [[self collectionView] reloadData];
        }
    }
}

- (HEMSleepSoundVolume*)volumeObjectForValue:(NSNumber*)value {
    NSArray<HEMSleepSoundVolume*>* volumes = [[self service] availableVolumeOptions];
    HEMSleepSoundVolume* object = [[self service] defaultVolume];
    for (HEMSleepSoundVolume* volume in volumes) {
        if ([volume volume] == [value CGFloatValue]) {
            object = volume;
            break;
        }
    }
    return object;
}

- (NSString*)titleForPlayerState:(HEMSleepSoundPlayerState)state {
    switch (state) {
        case HEMSleepSoundPlayerStateStopped:
            return NSLocalizedString(@"sleep-sounds.title.state.stopped", nil);
        case HEMSleepSoundPlayerStatePlaying:
            return NSLocalizedString(@"sleep-sounds.title.state.playing", nil);
        default:
            return [[[self configCell] titleLabel] text];
    }
}

#pragma mark - Temporary Sleep Sounds State

- (UIImage*)imageForState:(SENSleepSoundsFeatureState)state {
    switch (state) {
        case SENSleepSoundsFeatureStateFWRequired:
            return [UIImage imageNamed:@"sleepSoundSenseNeedsUpdate"];
        case SENSleepSoundsFeatureStateNoSounds:
            return [UIImage imageNamed:@"sleepSoundSenseDownloading"];
        case SENSleepSoundsFeatureStateOK:
            if ([self isSenseOffline]) {
                return [UIImage imageNamed:@"sleepSoundSenseOffline"];
            }
        default:
            return nil;
    }
}

- (NSAttributedString*)attributedInfoTitleForState:(SENSleepSoundsFeatureState)state {
    NSString* title = nil;
    
    switch (state) {
        case SENSleepSoundsFeatureStateFWRequired:
            title = NSLocalizedString(@"sleep-sounds.temp.info.title.fw-update", nil);
            break;
        case SENSleepSoundsFeatureStateNoSounds:
            title = NSLocalizedString(@"sleep-sounds.temp.info.title.no-sounds", nil);
            break;
        case SENSleepSoundsFeatureStateOK:
            if ([self isSenseOffline]) {
                title = NSLocalizedString(@"sleep-sounds.temp.info.title.offline", nil);
            }
            break;
        default:
            break;
    }
    
    if (!title) {
        return nil;
    }
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont partialDataTitleFont],
                                 NSForegroundColorAttributeName : [UIColor partialDataTitleColor]};
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSAttributedString*)attributedInfoMessageForState:(SENSleepSoundsFeatureState)state {
    NSString* message = nil;
    switch (state) {
        case SENSleepSoundsFeatureStateFWRequired:
            message = NSLocalizedString(@"sleep-sounds.temp.info.message.fw-update", nil);
            break;
        case SENSleepSoundsFeatureStateNoSounds:
            message = NSLocalizedString(@"sleep-sounds.temp.info.message.no-sounds", nil);
            break;
        case SENSleepSoundsFeatureStateOK:
            if ([self isSenseOffline]) {
                message = NSLocalizedString(@"sleep-sounds.temp.info.message.offline", nil);
            }
        default:
            break;
    }
    
    if (!message) {
        return nil;
    }
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont partialDataMessageFont],
                                 NSForegroundColorAttributeName : [UIColor partialDataMessageColor]};
    return [[NSAttributedString alloc] initWithString:message attributes:attributes];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // only ever return 1 configuration cell.  it's a collection view for extensibility
    // and to inherit card layout attributes and others
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStateSenseOffline:
        case HEMSleepSoundPlayerStatePrereqNotMet:
            reuseId = [HEMMainStoryboard messageReuseIdentifier];
            break;
        case HEMSleepSoundPlayerStateError:
            reuseId = [HEMMainStoryboard errorReuseIdentifier];
            break;
        default:
            reuseId = [HEMMainStoryboard settingsReuseIdentifier];
            break;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

#pragma mark - UICollectionView Layout Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* flowLayout = (id)collectionViewLayout;
    CGSize itemSize = [flowLayout itemSize];
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStateSenseOffline:
        case HEMSleepSoundPlayerStatePrereqNotMet: {
            SENSleepSoundsFeatureState state = [[self availableSounds] state];
            NSAttributedString* attrTitle = [self attributedInfoTitleForState:state];
            NSAttributedString* attrMessage = [self attributedInfoMessageForState:state];
            itemSize.height = [HEMIntroMessageCell heightWithTitle:attrTitle
                                                           message:attrMessage
                                                         withWidth:itemSize.width];
            break;
        }
        case HEMSleepSoundPlayerStateError: {
            NSString* text = NSLocalizedString(@"sleep-sounds.error.message", nil);
            UIFont* font = [UIFont errorStateDescriptionFont];
            CGFloat maxWidth = itemSize.width - (HEMStyleCardErrorTextHorzMargin * 2);
            CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
            itemSize.height = textHeight + (HEMStyleCardErrorTextVertMargin * 2);
            break;
        }
        default:
            itemSize.height = HEMSleepSoundConfigCellHeight;
            break;
    }
    return itemSize;
}

#pragma mark - UICollectionViewDelegate

- (void)configureIntroMessageCell:(HEMIntroMessageCell*)introCell {
    SENSleepSoundsFeatureState state = [[self availableSounds] state];
    [[introCell titleLabel] setAttributedText:[self attributedInfoTitleForState:state]];
    [[introCell messageLabel] setAttributedText:[self attributedInfoMessageForState:state]];
    [[introCell imageView] setImage:[self imageForState:state]];
}

- (void)configureSleepSoundConfigurationCell:(HEMSleepSoundConfigurationCell*)cell {
    [[cell titleLabel] setTextColor:[UIColor sleepSoundPlayerTitleColor]];
    [[cell titleLabel] setText:[self titleForPlayerState:[self playerState]]];
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
    [[cell volumeValueLabel] setText:[[self selectedVolume] localizedName]];
    [[cell volumeValueLabel] setTextColor:[UIColor sleepSoundPlayerOptionValueColor]];
    [[cell volumeSelectorButton] addTarget:self
                                    action:@selector(changeVolume:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [self setConfigCell:cell];
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)errorCell {
    [[errorCell textLabel] setText:NSLocalizedString(@"sleep-sounds.error.message", nil)];
    [[errorCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
    [errorCell displayAsACard:YES];
    [self setConfigCell:nil];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSleepSoundConfigurationCell class]]) {
        [self configureSleepSoundConfigurationCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMTextCollectionViewCell class]]) {
        [self configureErrorCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMIntroMessageCell class]]) {
        [self configureIntroMessageCell:(id)cell];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Player Actions

- (void)changeSound:(UIButton*)button {
    DDLogVerbose(@"change sound");
    [self setWaitingForOptionChange:YES];
    [[self delegate] showAvailableSounds:[[self availableSounds] sounds]
                       selectedSoundName:[[self selectedSound] localizedName]
                               withTitle:NSLocalizedString(@"sleep-sounds.option.title.sound", nil)
                                subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.sound", nil)
                                    from:self];
}

- (void)changeDuration:(UIButton*)button {
    DDLogVerbose(@"change duration");
    [self setWaitingForOptionChange:YES];
    [[self delegate] showAvailableDurations:[[self availableDurations] durations]
                       selectedDurationName:[[self selectedDuration] localizedName]
                                  withTitle:NSLocalizedString(@"sleep-sounds.option.title.duration", nil)
                                   subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.duration", nil)
                                       from:self];
}

- (void)changeVolume:(UIButton*)button {
    DDLogVerbose(@"change volume");
    [self setWaitingForOptionChange:YES];
    [[self delegate] showVolumeOptions:[[self service] availableVolumeOptions]
                    selectedVolumeName:[[self selectedVolume] localizedName]
                             withTitle:NSLocalizedString(@"sleep-sounds.option.title.volume", nil)
                              subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.volume", nil)
                                  from:self];
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

- (NSDictionary*)analyticPropertiesForSelectedOptions {
    NSNumber* soundId = [[self selectedSound] identifier] ?: @(-1);
    NSNumber* durationId = [[self selectedDuration] identifier] ?: @(-1);
    NSNumber* volume = @([[self selectedVolume] volume]);
    NSDictionary* props = @{HEMAnalyticsEventSSPropSoundId : soundId,
                            HEMAnalyticsEventSSPropDurationId : durationId,
                            HEMAnalyticsEventSSPropVolume : volume};
    return props;
}

- (void)play:(UIButton*)button {
    DDLogVerbose(@"attempting to play sound");
    [SENAnalytics track:HEMAnalyticsEventSSActionPlay
             properties:[self analyticPropertiesForSelectedOptions]];
    
    [self setPlayerState:HEMSleepSoundPlayerStateWaiting];
    
    __weak typeof(self) weakSelf = self;
    [[self service] playSound:[self selectedSound]
                  forDuration:[self selectedDuration]
                   withVolume:[[self selectedVolume] volume]
                   completion:^(NSError * _Nullable error) {
                       __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                       if (!error) {
                           DDLogVerbose(@"playing sound");
                           [strongSelf setPlayerState:HEMSleepSoundPlayerStatePlaying];
                       } else {
                           DDLogVerbose(@"failed to play sound");
                           [strongSelf setPlayerState:HEMSleepSoundPlayerStateStopped];
                           [strongSelf requestErrorToBeShown:error];
                       }
                       
                   }];
}

- (void)stop:(UIButton*)button {
    DDLogVerbose(@"attempting to stop sound");
    [SENAnalytics track:HEMAnalyticsEventSSActionStop];
    
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
            [strongSelf requestErrorToBeShown:error];
        }
    }];
}

#pragma mark - Errors

- (void)requestErrorToBeShown:(NSError*)error {
    NSString* message = [self translateError:error];
    NSString* title = NSLocalizedString(@"sleep-sounds.error.title", nil);
    [[self delegate] presentErrorWithTitle:title message:message];
}

- (NSString*)translateError:(NSError*)error {
    NSString* message = nil;
    if ([[error domain] isEqualToString:HEMSleepSoundServiceErrorDomain]) {
        switch ([error code]) {
            case HEMSleepSoundServiceErrorInProgress:
                message = NSLocalizedString(@"sleep-sounds.error.action-in-progress.message", nil);
                break;
            case HEMSleepSoundServiceErrorTimeout:
                message = NSLocalizedString(@"sleep-sounds.error.action-timeout.message", nil);
            default:
                break;
        }
    }
    return message ?: [error localizedDescription];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
