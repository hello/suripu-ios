//
//  HEMVoiceService.m
//  Sense
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENAPISpeech.h>
#import <SenseKit/SENSpeechResult.h>
#import <SenseKit/SENService+Protected.h>
#import <SenseKit/SENLocalPreferences.h>

#import "HEMVoiceService.h"
#import "HEMVoiceCommandGroup.h"

NSString* const HEMVoiceNotification = @"HEMVoiceNotificationResult";
NSString* const HEMVoiceNotificationInfoError = @"voice.error";
NSString* const HEMVoiceNotificationInfoResult = @"voice.result";

static CGFloat const HEMVoiceServiceWaitDelay = 1.0f;
static NSString* const HEMVoiceServiceHideIntroKey = @"HEMVoiceServiceIntroKey";

typedef void(^HEMVoiceCommandsHandler)(NSArray<SENSpeechResult*>* _Nullable results,
                                       NSError* _Nullable error);

@interface HEMVoiceService()

@property (nonatomic, assign, getter=isStarted) BOOL started;
@property (nonatomic, assign, getter=isInProgress) BOOL inProgress;
@property (nonatomic, strong) NSDate* lastVoiceResultDate;
@property (nonatomic, strong) NSArray<HEMVoiceCommandGroup*>* voiceCommands;

@end

@implementation HEMVoiceService

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastVoiceResultDate = [NSDate date];
    }
    return self;
}

#pragma mark - Speech responses

- (void)mostRecentVoiceCommands:(HEMVoiceCommandsHandler)completion {
    [SENAPISpeech getRecentVoiceCommands:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion(data, error);
    }];
}

- (void)startListeningForVoiceResult {
    if (![self isStarted]) {
        [self setStarted:YES];
        [self waitForVoiceCommandResult];
    }
}

- (void)waitForVoiceCommandResult {
    if ([self isInProgress]) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self setInProgress:YES];
    [self mostRecentVoiceCommands:^(NSArray<SENSpeechResult *> * results, NSError * error) {
        __strong typeof(weakSelf) strongself = weakSelf;
        NSDictionary* info = nil;
        
        if (error) {
            info = @{HEMVoiceNotificationInfoError : error};
        } else if ([results count] > 0) {
            SENSpeechResult* result = [results lastObject];
            NSDate* resultDate = [result date];
            if (![self lastVoiceResultDate]
                || [[self lastVoiceResultDate] compare:resultDate] == NSOrderedAscending) {
                [self setLastVoiceResultDate:resultDate];
                info = @{HEMVoiceNotificationInfoResult : [results lastObject]};
            }
        }
        
        if (info) {
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:HEMVoiceNotification
                                  object:strongself
                                userInfo:info];
        }
        
        int64_t delay = (int64_t)(HEMVoiceServiceWaitDelay * NSEC_PER_SEC);
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delay);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [strongself setInProgress:NO];
            if ([strongself isStarted]) {
                [strongself waitForVoiceCommandResult];
            }
        });
        
    }];
}

- (void)stopListeningForVoiceResult {
    [self setStarted:NO];
}

#pragma mark - Service overrides

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [self setVoiceCommands:nil];
}

#pragma mark - Commands

- (NSArray<HEMVoiceCommandGroup*>*)availableVoiceCommands {
    if (![self voiceCommands]) {
        // sounds
        HEMVoiceCommandExamples* alarmExamples = [HEMVoiceCommandExamples new];
        [alarmExamples setCategoryName:NSLocalizedString(@"voice.command.alarm.category.name", nil)];
        [alarmExamples setCommands:@[NSLocalizedString(@"voice.command.alarm.example.1", nil),
                                     NSLocalizedString(@"voice.command.alarm.example.2", nil)]];
        
        HEMVoiceCommandExamples* sleepSoundExamples = [HEMVoiceCommandExamples new];
        [sleepSoundExamples setCategoryName:NSLocalizedString(@"voice.command.sleep-sound.category.name", nil)];
        [sleepSoundExamples setCommands:@[NSLocalizedString(@"voice.command.sleep-sound.example.1", nil),
                                          NSLocalizedString(@"voice.command.sleep-sound.example.2", nil)]];
        
        HEMVoiceCommandGroup* soundsGroup = [HEMVoiceCommandGroup new];
        [soundsGroup setCategoryName:NSLocalizedString(@"voice.command.sound.category.name", nil)];
        [soundsGroup setMessage:NSLocalizedString(@"voice.command.sound.message", nil)];
        [soundsGroup setExamples:@[alarmExamples, sleepSoundExamples]];
        [soundsGroup setIconNameSmall:@"voiceSoundIconSmall"];
        [soundsGroup setIconNameLarge:@"voiceSoundIconLarge"];
        
        // sleep
        HEMVoiceCommandExamples* timelineExamples = [HEMVoiceCommandExamples new];
        [timelineExamples setCategoryName:NSLocalizedString(@"voice.command.timeline.category.name", nil)];
        [timelineExamples setCommands:@[NSLocalizedString(@"voice.command.timeline.example.1", nil),
                                        NSLocalizedString(@"voice.command.timeline.example.2", nil)]];
        
        HEMVoiceCommandGroup* sleepGroup = [HEMVoiceCommandGroup new];
        [sleepGroup setCategoryName:NSLocalizedString(@"voice.command.sleep.category.name", nil)];
        [sleepGroup setMessage:NSLocalizedString(@"voice.command.sleep.message", nil)];
        [sleepGroup setExamples:@[timelineExamples]];
        [sleepGroup setIconNameSmall:@"voiceSleepIconSmall"];
        [sleepGroup setIconNameLarge:@"voiceSleepIconLarge"];
        
        // room conditions
        HEMVoiceCommandExamples* tempExamples = [HEMVoiceCommandExamples new];
        [tempExamples setCategoryName:NSLocalizedString(@"voice.command.temperature.category.name", nil)];
        [tempExamples setCommands:@[NSLocalizedString(@"voice.command.temperature.example.1", nil)]];
        
        HEMVoiceCommandExamples* bedroomExamples = [HEMVoiceCommandExamples new];
        [bedroomExamples setCategoryName:NSLocalizedString(@"voice.command.bedroom.category.name", nil)];
        [bedroomExamples setCommands:@[NSLocalizedString(@"voice.command.bedroom.example.1", nil)]];
        
        HEMVoiceCommandExamples* humidityExamples = [HEMVoiceCommandExamples new];
        [humidityExamples setCategoryName:NSLocalizedString(@"voice.command.humidity.category.name", nil)];
        [humidityExamples setCommands:@[NSLocalizedString(@"voice.command.humidity.example.1", nil)]];
        
        HEMVoiceCommandExamples* noiseExamples = [HEMVoiceCommandExamples new];
        [noiseExamples setCategoryName:NSLocalizedString(@"voice.command.noise.category.name", nil)];
        [noiseExamples setCommands:@[NSLocalizedString(@"voice.command.noise.example.1", nil),
                                     NSLocalizedString(@"voice.command.noise.example.2", nil)]];
        
        HEMVoiceCommandExamples* airExamples = [HEMVoiceCommandExamples new];
        [airExamples setCategoryName:NSLocalizedString(@"voice.command.air.category.name", nil)];
        [airExamples setCommands:@[NSLocalizedString(@"voice.command.air.example.1", nil)]];
        
        HEMVoiceCommandGroup* conditionsGroup = [HEMVoiceCommandGroup new];
        [conditionsGroup setCategoryName:NSLocalizedString(@"voice.command.room-conditions.category.name", nil)];
        [conditionsGroup setMessage:NSLocalizedString(@"voice.command.room-conditions.message", nil)];
        [conditionsGroup setExamples:@[tempExamples,
                                       bedroomExamples,
                                       humidityExamples,
                                       noiseExamples,
                                       airExamples]];
        [conditionsGroup setIconNameSmall:@"voiceConditionsIconSmall"];
        [conditionsGroup setIconNameLarge:@"voiceConditionsIconLarge"];
        
        // expansion
        HEMVoiceCommandExamples* lightsExamples = [HEMVoiceCommandExamples new];
        [lightsExamples setCategoryName:NSLocalizedString(@"voice.command.lights.category.name", nil)];
        [lightsExamples setCommands:@[NSLocalizedString(@"voice.command.lights.example.1", nil),
                                      NSLocalizedString(@"voice.command.lights.example.2", nil),
                                      NSLocalizedString(@"voice.command.lights.example.3", nil)]];
        
        HEMVoiceCommandExamples* thermostatExamples = [HEMVoiceCommandExamples new];
        [thermostatExamples setCategoryName:NSLocalizedString(@"voice.command.thermostat.category.name", nil)];
        [thermostatExamples setCommands:@[NSLocalizedString(@"voice.command.thermostat.example.1", nil)]];
        
        HEMVoiceCommandGroup* expansionsGroup = [HEMVoiceCommandGroup new];
        [expansionsGroup setCategoryName:NSLocalizedString(@"voice.command.expansions.category.name", nil)];
        [expansionsGroup setMessage:NSLocalizedString(@"voice.command.expansions.message", nil)];
        [expansionsGroup setExamples:@[lightsExamples, thermostatExamples]];
        [expansionsGroup setIconNameSmall:@"voiceExpansionsIconSmall"];
        [expansionsGroup setIconNameLarge:@"voiceExpansionsIconLarge"];
        
        [self setVoiceCommands:@[soundsGroup, sleepGroup, conditionsGroup, expansionsGroup]];
    }
    return [self voiceCommands];
}

- (BOOL)showVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    return ![[localPrefs userPreferenceForKey:HEMVoiceServiceHideIntroKey] boolValue];
}

- (void)hideVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:@YES forKey:HEMVoiceServiceHideIntroKey];
}

- (void)resetVoiceIntro {
    SENLocalPreferences* localPrefs = [SENLocalPreferences sharedPreferences];
    [localPrefs setUserPreference:@NO forKey:HEMVoiceServiceHideIntroKey];
}

@end
