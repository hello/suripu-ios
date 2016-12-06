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
#import <SenseKit/SENSleepSoundsState.h>

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
#import "HEMTutorial.h"
#import "HEMStyle.h"

static CGFloat const HEMSleepSoundConfigCellHeight = 217.0f;
static CGFloat const HEMSleepSoundPlayerLoadAnimeDuration = 0.5f;

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
@property (nonatomic, weak) NSLayoutConstraint* actionBottomConstraint;
@property (nonatomic, assign) CGFloat origActionBottomDistance;
@property (nonatomic, strong) SENSleepSoundsState* soundState;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, strong) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, strong) SENSleepSound* selectedSound;
@property (nonatomic, strong) SENSleepSoundDuration* selectedDuration;
@property (nonatomic, strong) HEMSleepSoundVolume* selectedVolume;
@property (nonatomic, assign) HEMSleepSoundPlayerState playerState;
@property (nonatomic, weak) HEMSleepSoundConfigurationCell* configCell;
@property (nonatomic, weak) HEMActivityIndicatorView* indicator;
@property (nonatomic, assign, getter=isWaitingForOptionChange) BOOL waitingForOptionChange;
@property (nonatomic, assign, getter=isSenseOffline) BOOL senseOffline;
@property (nonatomic, weak) UIView* bgView;

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

- (void)bindWithBackgroundView:(UIView*)backgroundView {
    [backgroundView setHidden:NO];
    [self setBgView:backgroundView];
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setAlpha:0.0f];
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView setBackgroundColor:[UIColor backgroundColor]];
    [[collectionView superview] setBackgroundColor:[UIColor backgroundColor]];
    [self setCollectionView:collectionView];
}

- (void)bindWithActionButton:(UIButton*)button
            bottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [self setOrigActionBottomDistance:[bottomConstraint constant]];

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
    [self setActionBottomConstraint:bottomConstraint];
    [self setIndicatorView:[self activityIndicator]];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicator {
    [indicator setHidden:YES];
    [self setIndicator:indicator];
}

#pragma mark - Monitor Player Status

- (void)startMonitoring {
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStatePlaying:
        case HEMSleepSoundPlayerStateStopped:
        case HEMSleepSoundPlayerStateWaiting: {
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center addObserver:self
                       selector:@selector(didGetStatusNotification:)
                           name:HEMSleepSoundServiceNotifyStatus
                         object:[self service]];
            [[self service] startMonitoringStatusChange];
            break;
        }
        default:
            break;
    }
}

- (void)stopMonitoring {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HEMSleepSoundServiceNotifyInfoStatus object:nil];
    [[self service] stopMonitoringStatusChange];
}

- (void)didGetStatusNotification:(NSNotification*)note {
    SENSleepSoundStatus* status = [note userInfo][HEMSleepSoundServiceNotifyInfoStatus];
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStatePlaying:
            if (![status isPlaying]) {
                [self configurePlayerStateFromStatus:status];
                [self setPlayerState:HEMSleepSoundPlayerStateStopped];
            }
            break;
        case HEMSleepSoundPlayerStateStopped:
            if ([status isPlaying]) {
                [self configurePlayerStateFromStatus:status];
                [self setPlayerState:HEMSleepSoundPlayerStatePlaying];
            }
        default:
            break;
    }
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    
    if (![self isWaitingForOptionChange]) {
        [SENAnalytics track:HEMAnalyticsEventSleepSoundView];
        [self loadData];
    } else {
        [[self service] startMonitoringStatusChange];
    }
    
    [self setWaitingForOptionChange:NO];
    [self didScrollContentIn:[self collectionView]];
}

- (void)didDisappear {
    [super didDisappear];
    [self stopMonitoring];
}

- (void)didEnterBackground {
    [super didEnterBackground];
    [self stopMonitoring];
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    [self loadData];
}

#pragma mark -

- (void)hideActionButton {
    CGFloat height = CGRectGetHeight([[self actionButton] bounds]);
    CGFloat hiddenBottom = absCGFloat([self origActionBottomDistance]) + height;
    [[self actionBottomConstraint] setConstant:hiddenBottom];
}

- (void)preparePlayerForDataToBeLoaded {
    switch ([self playerState]) {
        case HEMSleepSoundPlayerStateError:
        case HEMSleepSoundPlayerStatePrereqNotMet:
        case HEMSleepSoundPlayerStateSenseOffline:
            [self hideActionButton];
            [[self indicator] setHidden:NO];
            [[self collectionView] setAlpha:0.0];
            break;
        case HEMSleepSoundPlayerStateWaiting: {
            [[self indicator] setAlpha:0.0];
            [[self indicator] start];
            [[self indicator] setHidden:NO];
            [UIView animateWithDuration:HEMSleepSoundPlayerLoadAnimeDuration animations:^{
                [[self indicator] setAlpha:1.0f];
            }];
            break;
        }
        default:
            break;
    }
}

- (void)loadDeviceState:(void(^)(void))completion {
    [self setSenseOffline:NO];
    
    __weak typeof(self) weakSelf = self;
    [[self deviceService] refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (devices) {
            NSDate* date = [[devices senseMetadata] lastSeenDate];
            BOOL senseOk = ![[strongSelf service] isSenseLastSeenGoingToBeAProblem:date];
            [weakSelf setSenseOffline:!senseOk];
        }
        completion ();
    }];
}

- (void)loadData {
    if ([self isLoading]) {
        return;
    }
    
    [self preparePlayerForDataToBeLoaded];
    [self setLoading:YES];
    [self setPlayerState:HEMSleepSoundPlayerStateWaiting];
    [[self collectionView] reloadData];
    
    dispatch_group_t dataGroup = dispatch_group_create();
    
    dispatch_group_enter(dataGroup);
    [self loadDeviceState:^{
        dispatch_group_leave(dataGroup);
    }];
    
    dispatch_group_enter(dataGroup);
    [self loadState:^{
        dispatch_group_leave(dataGroup);
    }];
    
    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoading:NO];
        [strongSelf configurePlayerStateFromStatus:[[strongSelf soundState] status]];
        [strongSelf startMonitoring];
        [[strongSelf collectionView] reloadData];
    });
}

- (void)loadState:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [[self service] currentSleepSoundsState:^(id  _Nullable data, NSError * _Nullable error) {
        [weakSelf setSoundState:data]; // error or not.  clear the state if error
        completion();
    }];
}

- (void)configurePlayerWithSavedState {
    // sound
    SENSleepSounds* sounds = [[self soundState] sounds];
    SENSleepSound* defaultSound = [[self service] defaultSleepSoundFrom:sounds];
    [self setSelectedSound:defaultSound save:NO];
    // duration
    SENSleepSoundDurations* durations = [[self soundState] durations];
    SENSleepSoundDuration* defaultDuration = [[self service] defaultDurationFrom:durations];
    [self setSelectedDuration:defaultDuration save:NO];
    // volume
    [self setSelectedVolume:[[self service] defaultVolume] save:NO];
}

- (void)configurePlayerStateFromStatus:(SENSleepSoundStatus*)status {
    if (!status) {
        [self setPlayerState:HEMSleepSoundPlayerStateError];
    } else if ([self isSenseOffline]) {
        [self reloadDataWithPlayerState:HEMSleepSoundPlayerStateSenseOffline];
    } else if (![[self service] isEnabled:[self soundState]]) {
        [self reloadDataWithPlayerState:HEMSleepSoundPlayerStatePrereqNotMet];
    } else if ([status isPlaying]) {
        [self setSelectedSound:[status sound] save:NO];
        [self setSelectedDuration:[status duration] save:NO];
        [self setSelectedVolume:[[self service] volumeObjectForValue:[status volume]] save:NO];
        [self setPlayerState:HEMSleepSoundPlayerStatePlaying];
    } else { // not playing, load what has been saved
        [self configurePlayerWithSavedState];
        [self setPlayerState:HEMSleepSoundPlayerStateStopped];
    }

    [[self indicator] stop];
    [[self indicator] setHidden:YES];
    [UIView animateWithDuration:HEMSleepSoundPlayerLoadAnimeDuration animations:^{
        [[self collectionView] setAlpha:1.0f];
        [[self actionBottomConstraint] setConstant:[self origActionBottomDistance]];
        [[self actionButton] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[self bgView] setHidden:YES];
    }];
}

- (void)reloadDataWithPlayerState:(HEMSleepSoundPlayerState)state {
    [self setPlayerState:state];
    [[self collectionView] reloadData];
}

- (void)setPlayerState:(HEMSleepSoundPlayerState)playerState {
    _playerState = playerState;

    [[self actionButton] setEnabled:YES];
    
    switch (playerState) {
        case HEMSleepSoundPlayerStateSenseOffline:
        case HEMSleepSoundPlayerStatePrereqNotMet:
            [[self configCell] setPlaying:NO];
            [[self actionButton] setHidden:YES];
            break;
        case HEMSleepSoundPlayerStateError:
            [[self configCell] setPlaying:NO];
            [[self indicatorView] stop];
            [[self indicatorView] removeFromSuperview];
            [[self actionButton] setHidden:YES];
            break;
        case HEMSleepSoundPlayerStateStopped:
            [[self indicatorView] stop];
            [[self indicatorView] removeFromSuperview];
            [[self configCell] setPlaying:NO];
            [[self actionButton] setHidden:NO];
            [[self actionButton] setImage:[UIImage imageNamed:@"sleepSoundPlayIcon"]
                                 forState:UIControlStateNormal];
            break;
        case HEMSleepSoundPlayerStatePlaying:
            [[self configCell] setPlaying:YES];
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

- (void)setSelectedSound:(SENSleepSound*)sound save:(BOOL)save {
    BOOL shouldReload = _selectedSound != nil;
    if (![[_selectedSound identifier] isEqualToNumber:[sound identifier]]) {
        _selectedSound = sound;
        if (shouldReload) {
            if (save) {
                [[self service] saveSelectedSoundSetting:sound];
            }
            [[self collectionView] reloadData];
        }
    }
}

- (void)setSelectedDuration:(SENSleepSoundDuration*)duration save:(BOOL)save {
    BOOL shouldReload = _selectedDuration != nil;
    if (![[_selectedDuration identifier] isEqualToNumber:[duration identifier]]) {
        _selectedDuration = duration;
        if (shouldReload) {
            if (save) {
                [[self service] saveSelectedDurationSetting:duration];
            }
            [[self collectionView] reloadData];
        }
    }
}

- (void)setSelectedVolume:(HEMSleepSoundVolume *)selectedVolume save:(BOOL)save {
    BOOL shouldReload = _selectedVolume != nil;
    if (![[_selectedVolume localizedName] isEqualToString:[selectedVolume localizedName]]) {
        _selectedVolume = selectedVolume;
        if (shouldReload) {
            if (save) {
                [[self service] saveSelectedVolumeSetting:selectedVolume];
            }
            [[self collectionView] reloadData];
        }
    }
}

#pragma mark - Temporary Sleep Sounds State

- (UIImage*)imageForState:(SENSleepSoundsFeatureState)state {
    if ([self isSenseOffline]) {
        return [UIImage imageNamed:@"sleepSoundSenseOffline"];
    } else {
        switch (state) {
            case SENSleepSoundsFeatureStateFWRequired:
                return [UIImage imageNamed:@"sleepSoundSenseNeedsUpdate"];
            case SENSleepSoundsFeatureStateNoSounds:
                return [UIImage imageNamed:@"sleepSoundSenseDownloading"];
            default:
                return nil;
        }
    }
}

- (NSAttributedString*)attributedInfoTitleForState:(SENSleepSoundsFeatureState)state {
    NSString* title = nil;
    if ([self isSenseOffline]) {
        title = NSLocalizedString(@"sleep-sounds.temp.info.title.offline", nil);
    } else {
        switch (state) {
            case SENSleepSoundsFeatureStateFWRequired:
                title = NSLocalizedString(@"sleep-sounds.temp.info.title.fw-update", nil);
                break;
            case SENSleepSoundsFeatureStateNoSounds:
                title = NSLocalizedString(@"sleep-sounds.temp.info.title.no-sounds", nil);
                break;
            default:
                break;
        }
    }
    
    if (!title) {
        return nil;
    }
    
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont bodyBold],
                                 NSForegroundColorAttributeName : [UIColor grey5]};
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (NSAttributedString*)attributedInfoMessageForState:(SENSleepSoundsFeatureState)state {
    NSString* message = nil;
    if ([self isSenseOffline]) {
        message = NSLocalizedString(@"sleep-sounds.temp.info.message.offline", nil);
    } else {
        switch (state) {
            case SENSleepSoundsFeatureStateFWRequired:
                message = NSLocalizedString(@"sleep-sounds.temp.info.message.fw-update", nil);
                break;
            case SENSleepSoundsFeatureStateNoSounds:
                message = NSLocalizedString(@"sleep-sounds.temp.info.message.no-sounds", nil);
                break;
            default:
                break;
        }
    }
    
    if (!message) {
        return nil;
    }
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont body],
                                 NSForegroundColorAttributeName : [UIColor lowImportanceTextColor]};
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
            SENSleepSoundsFeatureState state = [[[self soundState] sounds] state];
            NSAttributedString* attrTitle = [self attributedInfoTitleForState:state];
            NSAttributedString* attrMessage = [self attributedInfoMessageForState:state];
            itemSize.height = [HEMIntroMessageCell heightWithTitle:attrTitle
                                                           message:attrMessage
                                                         withWidth:itemSize.width];
            break;
        }
        case HEMSleepSoundPlayerStateError: {
            NSString* text = NSLocalizedString(@"sleep-sounds.error.message", nil);
            UIFont* font = [UIFont body];
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
    SENSleepSoundsFeatureState state = [[[self soundState] sounds] state];
    [[introCell titleLabel] setAttributedText:[self attributedInfoTitleForState:state]];
    [[introCell messageLabel] setAttributedText:[self attributedInfoMessageForState:state]];
    [[introCell imageView] setImage:[self imageForState:state]];
}

- (void)configureSleepSoundConfigurationCell:(HEMSleepSoundConfigurationCell*)cell {
    UIColor* titleColor = [UIColor cardTitleColor];
    UIColor* typeColor = [UIColor cardTitleColor];
    UIColor* valueColor = [UIColor detailTextColor];
    
    [[cell titleLabel] setTextColor:titleColor];
    [[cell titleLabel] setText:NSLocalizedString(@"sleep-sounds.title.state.stopped", nil)];
    [[cell playingLabel] setText:NSLocalizedString(@"sleep-sounds.title.state.playing", nil)];
    [[cell playingLabel] setTextColor:titleColor];
    
    [[cell soundLabel] setTextColor:typeColor];
    [[cell soundValueLabel] setText:[[self selectedSound] localizedName]];
    [[cell soundValueLabel] setTextColor:valueColor];
    [[cell soundSelectorButton] addTarget:self
                                   action:@selector(changeSound:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [[cell durationLabel] setTextColor:typeColor];
    [[cell durationValueLabel] setText:[[self selectedDuration] localizedName]];
    [[cell durationValueLabel] setTextColor:valueColor];
    [[cell durationSelectorButton] addTarget:self
                                      action:@selector(changeDuration:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [[cell volumeLabel] setTextColor:typeColor];
    [[cell volumeValueLabel] setText:[[self selectedVolume] localizedName]];
    [[cell volumeValueLabel] setTextColor:valueColor];
    [[cell volumeSelectorButton] addTarget:self
                                    action:@selector(changeVolume:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [self setConfigCell:cell];
}

- (void)configureErrorCell:(HEMTextCollectionViewCell*)errorCell {
    [[errorCell textLabel] setText:NSLocalizedString(@"sleep-sounds.error.message", nil)];
    [[errorCell textLabel] setFont:[UIFont body]];
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
    [[self delegate] showAvailableSounds:[[[self soundState] sounds] sounds]
                       selectedSoundName:[[self selectedSound] localizedName]
                               withTitle:NSLocalizedString(@"sleep-sounds.option.title.sound", nil)
                                subTitle:NSLocalizedString(@"sleep-sounds.option.subtitle.sound", nil)
                                    from:self];
}

- (void)changeDuration:(UIButton*)button {
    DDLogVerbose(@"change duration");
    [self setWaitingForOptionChange:YES];
    [[self delegate] showAvailableDurations:[[[self soundState] durations] durations]
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
            [strongSelf configurePlayerWithSavedState];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
