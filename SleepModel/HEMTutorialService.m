//
//  HEMTutorialService.m
//  Sense
//
//  Created by Jimmy Lu on 1/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>

#import "HEMTutorialService.h"

static NSString* const HEMTutorialServicePrefName = @"tutorials";

// insights
static NSString* const HEMTutorialServiceInsightTap = @"HandholdingInsightTap";
static NSString* const HEMTutorialHHInsightDaySwitchCounter = @"HandholdingInsightDaySwitchCounter";
static NSInteger const HEMTutorialHHInsightTapMinDaysChecked = 1;

// sensors
static NSString* const HEMTutorialHHSensorScrubbing = @"HandholdingSensorScrubbing";

@interface HEMTutorialService()

@property (nonatomic, strong) NSMutableDictionary* tutorialRecordKeeper;

@end

@implementation HEMTutorialService

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadRecordKeeper];
    }
    return self;
}

- (void)loadRecordKeeper {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    NSMutableDictionary* recordKeeper = [[prefs persistentPreferenceForKey:HEMTutorialServicePrefName] mutableCopy];
    if (!recordKeeper) {
        // migrate over the previously saved data
        recordKeeper = [NSMutableDictionary new];
        [recordKeeper setValue:[self oldTutorialRecord:HEMTutorialServiceInsightTap]
                        forKey:HEMTutorialServiceInsightTap];
        [recordKeeper setValue:[self oldTutorialRecord:HEMTutorialHHSensorScrubbing]
                        forKey:HEMTutorialHHSensorScrubbing];
    }
}

- (BOOL)isComplete:(NSString*)tutorialName {
    return ![[self tutorialRecordKeeper][tutorialName] boolValue];
}

- (void)completed:(NSString*)tutorialName {
    [self tutorialRecordKeeper][tutorialName] = @YES;
    
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:[self tutorialRecordKeeper]
                            forKey:HEMTutorialServicePrefName];
}

- (void)reset {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:nil forKey:HEMTutorialServicePrefName];
    [[self tutorialRecordKeeper] removeAllObjects];
}

#pragma mark - Deprecated storage

- (NSNumber*)oldTutorialRecord:(NSString*)tutorialName {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSNumber* currentValue = [preferences persistentPreferenceForKey:tutorialName];
    if (!currentValue) {
        currentValue = [preferences sessionPreferenceForKey:tutorialName];
    }
    return currentValue;
}

@end
