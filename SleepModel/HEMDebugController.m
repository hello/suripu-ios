//
//  HEMDebugController.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>

#import <SenseKit/API.h>
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENServiceDevice.h>
#import <SenseKit/SENPairedDevices.h>
#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENSensorStatus.h>

#import "HEMDebugController.h"
#import "HEMActionSheetViewController.h"
#import "HEMOnboardingService.h"
#import "HEMOnboardingStoryboard.h"
#import "HEMStyledNavigationViewController.h"
#import "HEMSettingsNavigationController.h"
#import "HEMMainStoryboard.h"
#import "UIColor+HEMStyle.h"
#import "HEMTutorial.h"
#import "HEMOnboardingController.h"
#import "HEMInfoViewController.h"
#import "HEMDebugInfoDataSource.h"
#import "HEMSelectHostViewController.h"
#import "HEMConfig.h"
#import "HEMHandHoldingService.h"
#import "HEMSleepSoundViewController.h"
#import "HEMAlarmService.h"
#import "HEMWhatsNewService.h"
#import "HEMAppUsage.h"
#import "HEMUpgradeSensePresenter.h"
#import "HEMHaveSenseViewController.h"
#import "HEMUpgradeFlow.h"
#import "HEMResetSenseViewController.h"
#import "HEMDeviceService.h"
#import "HEMSensorService.h"
#import "HEMRoomCheckViewController.h"
#import "HEMIntroService.h"
#import "HEMVoiceService.h"

@interface HEMDebugController()<MFMailComposeViewControllerDelegate>

@property (weak,   nonatomic) UIViewController*   presentingController;
@property (strong, nonatomic) HEMActionSheetViewController* supportOptionController;
@property (weak,   nonatomic) UIViewController* roomCheckViewController;
@property (weak,   nonatomic) UIViewController* sleepSoundsViewController;
@property (assign, nonatomic) UIModalPresentationStyle origPresentationStyle;
@property (strong, nonatomic) HEMSensorService* sensorService;

@end

@implementation HEMDebugController

+ (void)disableDebugMenuIfNeeded {
    if (![self isEnabled]) {
        [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    }
}

+ (BOOL)isEnabled {
    return [HEMConfig booleanForConfig:HEMConfAllowDebugOptions];
}

- (id)initWithViewController:(UIViewController*)controller {
    self = [super init];
    if (self) {
        [self setPresentingController:controller];
        [self setOrigPresentationStyle:[[self presentingController] modalPresentationStyle]];
    }
    return self;
}

- (void)setSupportOptionController:(HEMActionSheetViewController *)supportOptionController {
    _supportOptionController = supportOptionController;
    if (_supportOptionController == nil) {
        [[self presentingController] setModalPresentationStyle:[self origPresentationStyle]];
    }
}

- (void)showController:(UIViewController*)controller
              animated:(BOOL)animated
            completion:(void (^)(void))completion{
    
    UIViewController* parent = [self presentingController];
    while ([parent presentedViewController]) {
        parent = [parent presentedViewController];
    }
    [parent presentViewController:controller animated:animated completion:completion];
}

- (void)showSupportOptions {
    if ([self supportOptionController] != nil) return; // don't show it if showing now

    HEMActionSheetViewController* sheet =
        [HEMMainStoryboard instantiateActionSheetViewController];
    [sheet setTitle:NSLocalizedString(@"debug.options.title", nil)];
    
    [self addRoomCheckOptionTo:sheet];
    [self addShowVoiceTutorialOptionToSheet:sheet];
    [self addShowUpgradePathOptionToSheet:sheet];
    [self addFactoryResetScreenToSheet:sheet];
    [self addPillDfuOptionTo:sheet];
    [self addResetTutorialsOptionTo:sheet];
    [self addWhatsNewOptionTo:sheet];
    [self addForceAppReviewPrompt:sheet];
    [self addRemoveAllAlarmsOptionTo:sheet];
    [self addDebugInfoOptionTo:sheet];
    [self addChangeServerOptionToSheet:sheet];
    [self addCancelOptionTo:sheet];
    
    [self setSupportOptionController:sheet];
    
    [sheet addDismissAction:^{
        [self setSupportOptionController:nil];
    }];
    
    [self showController:sheet animated:NO completion:nil];
}

- (void)addDebugInfoOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.debug.info", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showDebugInfo];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)addForceAppReviewPrompt:(HEMActionSheetViewController*)sheet {
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.force.appreview", nil) action:^{
        [HEMAppUsage reset];
        
        // add timeline usage
        HEMAppUsage* timelineUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageTimelineShownWithData];
        for(int i = 0; i < 10; i++) {
            [timelineUsage increment:NO];
        }
        [timelineUsage save];
        
        HEMAppUsage* appLaunchUsage = [HEMAppUsage appUsageForIdentifier:HEMAppUsageAppLaunched];
        for (int i = 0; i < 5; i++) {
            [appLaunchUsage increment:NO];
        }
        [appLaunchUsage save];
        
        SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
        [localPrefs setPersistentPreference:nil forKey:@"stop.asking.to.rate.app"];
    }];
}

- (void)addChangeServerOptionToSheet:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.change-api-address", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showSelectHostController];
        [strongSelf setSupportOptionController:nil];
    }];
}

#pragma mark Upgrade path

- (void)addShowUpgradePathOptionToSheet:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.upgrade", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showUpgradePath];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)showUpgradePath {
    SENServiceDevice* deviceService = [SENServiceDevice sharedService];
    NSString* currentSenseId = [[[deviceService devices] senseMetadata] uniqueId];
    UIViewController* upgradeVC = [HEMUpgradeFlow rootViewControllerForFlowWithCurrentSenseId:currentSenseId];
    
    HEMStyledNavigationViewController* nav
        = [[HEMStyledNavigationViewController alloc] initWithRootViewController:upgradeVC];
    [self showController:nav animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEndOnboarding)
                                                 name:HEMOnboardingNotificationComplete
                                               object:nil];
}

#pragma mark Factory Reset

- (void)addFactoryResetScreenToSheet:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.reset", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showFactoryReset];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)showFactoryReset {
    HEMDeviceService* service = [HEMDeviceService new];
    __weak typeof(self) weakSelf = self;
    void(^show)(NSString* senseId) = ^(NSString* senseId) {
        __strong typeof(weakSelf) strongself = self;
        HEMResetSenseViewController* resetVC = [HEMOnboardingStoryboard instantiateResetSenseViewController];
        [resetVC setSenseId:senseId];
        [resetVC setDeviceService:service];
        [resetVC setCancellable:YES];
        
        UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:resetVC];
        [strongself showController:nav animated:YES completion:nil];
    };
    
    if ([service devices]) {
        if ([[service devices] hasPairedSense]) {
            show ([[[service devices] senseMetadata] uniqueId]);
        }
    } else {
        [service refreshMetadata:^(SENPairedDevices * devices, NSError * error) {
            if ([devices hasPairedSense]) {
                show ([[devices senseMetadata] uniqueId]);
            }
        }];
    }

}

#pragma mark Voice Tutorial

- (void)addShowVoiceTutorialOptionToSheet:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.voice", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showVoiceTutorial];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)showVoiceTutorial {
    UIViewController* voiceVC = [HEMOnboardingStoryboard instantiateVoiceTutorialViewController];
    HEMStyledNavigationViewController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:voiceVC];
    [self showController:nav animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEndOnboarding)
                                                 name:HEMOnboardingNotificationComplete
                                               object:nil];
}

- (void)didEndOnboarding {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HEMOnboardingNotificationComplete
                                                  object:nil];
    [[self presentingController] dismissViewControllerAnimated:YES completion:nil];
    
    [self setRoomCheckViewController:nil];
}

#pragma mark Debug Info

- (void)showDebugInfo {
    UINavigationController* navVC = [HEMMainStoryboard instantiateInfoNavigationController];
    HEMInfoViewController* infoVC = (id)[navVC topViewController];
    [infoVC setTitle:NSLocalizedString(@"debug.option.debug.info", nil)];
    
    HEMDebugInfoDataSource* source = [[HEMDebugInfoDataSource alloc] init];
    [infoVC setInfoSource:source];
    
    [self showController:navVC animated:YES completion:nil];
}

#pragma mark API Address

- (void)showSelectHostController {
    HEMSelectHostViewController *selectHost = [HEMSelectHostViewController new];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:selectHost];
    [self showController:navigation animated:YES completion:nil];
}

#pragma mark Room Check

- (void)addRoomCheckOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.room-check.title", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showRoomCheckController];
        [strongSelf setSupportOptionController:nil];
    }];
}

- (void)showRoomCheckController {
    void(^show)(NSArray* sensors) = ^(NSArray* sensors){
        HEMRoomCheckViewController* rcVC = [HEMOnboardingStoryboard instantiateRoomCheckViewController];
        [rcVC setSensors:sensors];
        
        UINavigationController* nav = [[HEMStyledNavigationViewController alloc] initWithRootViewController:rcVC];
        [self showController:nav animated:YES completion:nil];
        
        [self setRoomCheckViewController:nav];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEndOnboarding)
                                                     name:HEMOnboardingNotificationComplete
                                                   object:nil];
    };
    
    [self setSensorService:[HEMSensorService new]];
    [[self sensorService] sensorStatus:^(SENSensorStatus * status, NSError * error) {
        show([status sensors]);
    }];
}

#pragma mark - Alarms

- (void)addRemoveAllAlarmsOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.clear-alarms", nil) action:^{
        HEMAlarmService* service = [HEMAlarmService new];
        [service updateAlarms:@[] completion:nil];
        [weakSelf setSupportOptionController:nil];
    }];
}

#pragma mark - Dfu

- (void)addPillDfuOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.dfu.pill", nil) action:^{
        UIViewController* viewController = [HEMMainStoryboard instantiatePillDFUNavViewController];
        [weakSelf showController:viewController animated:YES completion:nil];
        [self setSupportOptionController:nil];
    }];
}

#pragma mark - Whats New

- (void)addWhatsNewOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.force-whats-new", nil) action:^{
        [HEMWhatsNewService forceToShow];
        [weakSelf setSupportOptionController:nil];
    }];
}

#pragma mark - Tutorials

- (void)addResetTutorialsOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"debug.option.reset-tutorials", nil) action:^{
        HEMIntroService* intro = [HEMIntroService new];
        [intro reset];
        
        HEMVoiceService* voice = [HEMVoiceService new];
        [voice resetVoiceIntro];
        
        HEMHandHoldingService* handHoldingService = [HEMHandHoldingService new];
        [handHoldingService reset];
        
        [HEMTutorial resetTutorials];
        
        [weakSelf setSupportOptionController:nil];
    }];
}

#pragma mark Cancel

- (void)addCancelOptionTo:(HEMActionSheetViewController*)sheet {
    __weak typeof(self) weakSelf = self;
    [sheet addOptionWithTitle:NSLocalizedString(@"actions.cancel", nil) action:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setSupportOptionController:nil];
    }];
}

#pragma mark Support Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [[controller presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Common Actions

- (void)dismissController:(id)sender {
    [[self presentingController] dismissViewControllerAnimated:YES completion:^{
        [self setSupportOptionController:nil];
        [self setSleepSoundsViewController:nil];
        [self setRoomCheckViewController:nil];
    }];
}

@end
