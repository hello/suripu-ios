//
//  HEMSoundSwitchPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSleepSounds.h>
#import <SenseKit/SENServiceDevice.h>

#import "NSString+HEMUtils.h"

#import "HEMStyle.h"
#import "HEMSoundsContentPresenter.h"
#import "HEMActivityIndicatorView.h"
#import "HEMSubNavigationView.h"
#import "HEMSleepSoundService.h"
#import "HEMOnboardingService.h"
#import "HEMDeviceService.h"
#import "HEMAlarmService.h"
#import "HEMMainStoryboard.h"
#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMTextCollectionViewCell.h"
#import "HEMActionButton.h"
#import "HEMShortcutService.h"

typedef NS_ENUM(NSUInteger, HEMSoundsSubNavOption) {
    HEMSoundsSubNavOptionAlarms = 1,
    HEMSoundsSubNavOptionSleepSounds
};

static CGFloat const HEMSoundsContentNoSenseCellHeight = 352.f;

@interface HEMSoundsContentPresenter() <
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMSleepSoundService* sleepSoundService;
@property (nonatomic, weak) HEMAlarmService* alarmService;
@property (nonatomic, weak) HEMDeviceService* deviceService;
@property (nonatomic, weak) HEMShortcutService* shortcutService;
@property (nonatomic, weak) HEMActivityIndicatorView* activityIndicator;
@property (nonatomic, weak) HEMSubNavigationView* subNav;
@property (nonatomic, assign) CGFloat origSubNavHeight;
@property (nonatomic, weak) NSLayoutConstraint* subNavHeightConstraint;
@property (nonatomic, strong) SENSleepSounds* availableSleepSounds;
@property (nonatomic, weak) UICollectionView* errorCollectionView;
@property (nonatomic, strong) NSError* deviceError;
@property (nonatomic, strong) NSNumber* pendingShortcutAction;
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;

@end

@implementation HEMSoundsContentPresenter

- (instancetype)initWithSleepSoundService:(HEMSleepSoundService*)sleepSoundService
                             alarmService:(HEMAlarmService*)alarmService
                            deviceService:(HEMDeviceService*)deviceService
                          shortcutService:(HEMShortcutService*)shortcutService {
    self = [super init];
    if (self) {
        _sleepSoundService = sleepSoundService;
        _alarmService = alarmService;
        _deviceService = deviceService;
        _shortcutService = shortcutService;
        
        [self listenForShortcutNotifications];
    }
    return self;
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator setHidden:NO];
    [activityIndicator start];
    [self setActivityIndicator:activityIndicator];
}

- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNavigationView
             withHeightConstraint:(NSLayoutConstraint*)heightConstraint {
    // hide the sub nav until determined that we need it
    [self setOrigSubNavHeight:[heightConstraint constant]];
    [heightConstraint setConstant:0.0f];
    
    [self setSubNav:subNavigationView];
    [self setSubNavHeightConstraint:heightConstraint];
    [self loadData];
}

- (void)bindWithErrorCollectionView:(UICollectionView*)collectionView {
    [self setErrorCollectionView:collectionView];
    [self listenForDeviceChanges];
}

- (void)listenForDeviceChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reload)
                   name:SENServiceDeviceNotificationFactorySettingsRestored
                 object:nil];
    [center addObserver:self
               selector:@selector(reload)
                   name:SENServiceDeviceNotificationSenseUnpaired
                 object:nil];
    [center addObserver:self
               selector:@selector(reload)
                   name:HEMOnboardingNotificationDidChangeSensePairing
                 object:nil];
}

- (BOOL)shouldReload {
    return [self deviceError]
        || ![[[self deviceService] devices] hasPairedSense]
        || ![self availableSleepSounds];
}

#pragma mark - Presenter events

- (void)didAppear {
    [super didAppear];
    if ([self shouldReload]) {
        [self reload];
    }
}

- (void)didComeBackFromBackground {
    [super didComeBackFromBackground];
    if ([self shouldReload]) {
        [self reload];
    }
}

#pragma mark - 3D Touch / Shortcut Support

- (void)listenForShortcutNotifications {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(reactToShortcut:)
                   name:nil
                 object:[self shortcutService]];
}

- (void)reactToShortcut:(NSNotification*)note {
    NSNumber* action = [note userInfo][HEMShortcutNoteInfoAction];
    switch ([action unsignedIntegerValue]) {
        case HEMShortcutActionAlarmNew:
        case HEMShortcutActionAlarmEdit: {
            if ([self isLoaded]) {
                [self showAlarmWithShortcutAction:[action unsignedIntegerValue]];
            } else {
                [self setPendingShortcutAction:action];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark -

- (void)showAlarmWithShortcutAction:(HEMShortcutAction)action {
    if (![[self errorCollectionView] isHidden]) {
        return;
    }
    switch (action) {
        case HEMShortcutActionAlarmNew:
            [[self subNav] selectControlWithTag:HEMSoundsSubNavOptionAlarms];
            [[self delegate] loadAlarmsFrom:self thenLaunchNewAlarm:YES];
            break;
        case HEMShortcutActionAlarmEdit: {
            [[self subNav] selectControlWithTag:HEMSoundsSubNavOptionAlarms];
            [[self delegate] loadAlarmsFrom:self thenLaunchNewAlarm:NO];
            break;
        }
        default:
            break;
    }
}

- (NSString*)localizedTitleFor:(HEMSoundsSubNavOption)option {
    switch (option) {
        default:
        case HEMSoundsSubNavOptionAlarms:
            return [NSLocalizedString(@"alarms.title", nil) uppercaseString];
        case HEMSoundsSubNavOptionSleepSounds:
            return [NSLocalizedString(@"sleep-sounds.title", nil) uppercaseString];
    }
}

- (UIButton*)soundButtonFor:(HEMSoundsSubNavOption)option selected:(BOOL)selected {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitle:[self localizedTitleFor:option] forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont subNavTitleTextFont]];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor subNavActiveTitleColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor subNavInactiveTitleColor] forState:UIControlStateNormal];
    [button setSelected:selected];
    [button setTag:option];
    [button addTarget:self action:@selector(changeOption:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)configureSubNavIfNeeded {
    if (![[self subNav] hasControls] && [self availableSleepSounds]) {
        [[self subNavHeightConstraint] setConstant:[self origSubNavHeight]];
        
        [[self subNav] addControl:[self soundButtonFor:HEMSoundsSubNavOptionAlarms selected:YES]];
        [[self subNav] addControl:[self soundButtonFor:HEMSoundsSubNavOptionSleepSounds selected:NO]];
        
        [[self subNav] setNeedsDisplay];
    }
}

- (void)stopActivityAndLoad {
    [self setLoaded:YES];
    [[self activityIndicator] stop];
    [[self activityIndicator] setHidden:YES];
    
    if ([self deviceError]) {
        [self displayDeviceError];
    } else if (![[[self deviceService] devices] hasPairedSense]) {
        [self displayNoSenseMessage];
    } else if ([self pendingShortcutAction]) {
        [self configureSubNavIfNeeded];
        [self showAlarmWithShortcutAction:[[self pendingShortcutAction] unsignedIntegerValue]];
    } else {
        [self hideErrorMessage];
        
        if (![[self subNav] hasControls]) {
            [self configureSubNavIfNeeded];
            [[self delegate] loadAlarmsFrom:self thenLaunchNewAlarm:NO];
        } else if ([[self subNav] selectedControlTag] == HEMSoundsSubNavOptionSleepSounds) {
            [[self delegate] loadSleepSounds:[self availableSleepSounds] from:self];
        } else {
            [[self delegate] loadAlarmsFrom:self thenLaunchNewAlarm:NO];
        }
    }
    
    [self setPendingShortcutAction:nil];
}

- (void)loadData {
    __weak typeof(self) weakSelf = self;
    
    [self checkDeviceRequirement:^(BOOL meetsRequirements) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!meetsRequirements) {
            [strongSelf stopActivityAndLoad];
        } else {
            [[strongSelf sleepSoundService] availableSleepSounds:^(id _Nullable data, NSError * _Nullable error) {
                
                if ([data isKindOfClass:[SENSleepSounds class]]) {
                    [strongSelf setAvailableSleepSounds:data];
                }
                
                [strongSelf stopActivityAndLoad];
            }];
        }
    }];
}

- (void)checkDeviceRequirement:(void(^)(BOOL meetsRequirements))completion {
    __weak typeof(self) weakSelf = self;
    [[self deviceService] refreshMetadata:^(SENPairedDevices * _Nullable devices, NSError * _Nullable error) {
        [weakSelf setDeviceError:error];
        completion ([devices hasPairedSense]);
    }];
}

- (void)reload {
    [self hideErrorMessage];
    [[self activityIndicator] setHidden:NO];
    [[self activityIndicator] start];
    [self loadData];
}

#pragma mark - Errors

- (void)displayDeviceError {
    if (![[self subNav] hasControls]) {
        [[self delegate] unloadContentControllersFrom:self];
        [[self errorCollectionView] setHidden:NO];
        [[self errorCollectionView] setDelegate:self];
        [[self errorCollectionView] setDataSource:self];
        [[self errorCollectionView] reloadData];
    }
}

- (void)displayNoSenseMessage {
    [[self subNavHeightConstraint] setConstant:0.0f];
    [[self subNav] reset];
    [[self delegate] unloadContentControllersFrom:self];
    
    [[self errorCollectionView] setHidden:NO];
    [[self errorCollectionView] setDelegate:self];
    [[self errorCollectionView] setDataSource:self];
    [[self errorCollectionView] reloadData];
}

- (void)hideErrorMessage {
    [[self errorCollectionView] setDelegate:self];
    [[self errorCollectionView] setDataSource:self];
    [[self errorCollectionView] setHidden:YES];
}

#pragma mark Collection View Delegate / DataSource

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    UICollectionViewFlowLayout* layout = (id) [collectionView collectionViewLayout];
    CGSize itemSize = [layout itemSize];
    
    if ([self deviceError]) {
        NSString* text = NSLocalizedString(@"sounds.error.message", nil);
        UIFont* font = [UIFont errorStateDescriptionFont];
        CGFloat maxWidth = itemSize.width - (HEMStyleCardErrorTextHorzMargin * 2);
        CGFloat textHeight = [text heightBoundedByWidth:maxWidth usingFont:font];
        itemSize.height = textHeight + (HEMStyleCardErrorTextVertMargin * 2);
    } else {
        itemSize.height = HEMSoundsContentNoSenseCellHeight;
    }
    
    return itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = nil;
    if ([self deviceError]) {
        reuseId = [HEMMainStoryboard errorReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard pairReuseIdentifier];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMSenseRequiredCollectionViewCell class]]) {
        HEMSenseRequiredCollectionViewCell* senseCell = (id)cell;
        [[senseCell descriptionLabel] setText:NSLocalizedString(@"sounds.no-sense.message", nil)];
        [[senseCell pairSenseButton] addTarget:self action:@selector(pairSense:) forControlEvents:UIControlEventTouchUpInside];
        [[senseCell pairSenseButton] setTitle:[NSLocalizedString(@"sounds.no-sense.button.title", nil) uppercaseString]
                                     forState:UIControlStateNormal];
    } else {
        HEMTextCollectionViewCell* textCell = (id)cell;
        [[textCell textLabel] setText:NSLocalizedString(@"sounds.error.message", nil)];
        [[textCell textLabel] setFont:[UIFont errorStateDescriptionFont]];
        [textCell displayAsACard:YES];
    }
}

#pragma mark - Actions

- (void)changeOption:(UIButton*)optionButton {
    switch ([optionButton tag]) {
        case HEMSoundsSubNavOptionAlarms:
            [[self delegate] loadAlarmsFrom:self thenLaunchNewAlarm:NO];
            break;
        case HEMSoundsSubNavOptionSleepSounds:
        default:
            [[self delegate] loadSleepSounds:[self availableSleepSounds] from:self];
            break;
    }
}

- (void)pairSense:(id)sender {
    DDLogVerbose(@"pair Sense from sounds content presenter");
    [[self delegate] pairWithSenseFrom:self];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_errorCollectionView) {
        [_errorCollectionView setDataSource:nil];
        [_errorCollectionView setDelegate:nil];
    }
}

@end
