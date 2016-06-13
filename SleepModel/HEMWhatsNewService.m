//
//  HEMWhatsNewService.m
//  Sense
//
//  Created by Jimmy Lu on 6/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENLocalPreferences.h>

#import "HEMWhatsNewService.h"

static NSString* const HEMWhatsNewServiceSetting = @"is.hello.sense.whats-new.version";
static NSString* const HEMWhatsNewServiceSettingDebug = @"is.hello.sense.whats-new.debug";

@implementation HEMWhatsNewService

+ (void)forceToShow {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:nil forKey:HEMWhatsNewServiceSetting];
    [prefs setPersistentPreference:@YES forKey:HEMWhatsNewServiceSettingDebug];
}

- (NSString*)currentVersion {
    NSBundle* bundle = [NSBundle mainBundle];
    return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (BOOL)shouldShow {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    NSString* currentVersion = [self currentVersion];
    NSString* lastVersionShown = [prefs persistentPreferenceForKey:HEMWhatsNewServiceSetting];
    NSString* title = [self title];
    NSString* message = [self message];
    return [title length] > 0
        && [message length] > 0
        && ![lastVersionShown isEqualToString:currentVersion];
}

- (void)dismiss {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    [prefs setPersistentPreference:[self currentVersion] forKey:HEMWhatsNewServiceSetting];
    [prefs setPersistentPreference:@NO forKey:HEMWhatsNewServiceSettingDebug];
}

- (BOOL)shouldShowAsDebug {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    return [[prefs persistentPreferenceForKey:HEMWhatsNewServiceSettingDebug] boolValue];
}

- (NSString*)title {
    NSString* title = NSLocalizedString(@"whats.new.title", nil);
    if ([title length] == 0 && [self shouldShowAsDebug]) {
        title = NSLocalizedString(@"whats.new.title.debug", nil);
    }
    return title;
}

- (NSString*)message {
    NSString* message = NSLocalizedString(@"whats.new.message", nil);
    if ([message length] == 0 && [self shouldShowAsDebug]) {
        message = NSLocalizedString(@"whats.new.message.debug", nil);
    }
    return message;
}

- (NSString*)buttonTitle {
    NSString* button = NSLocalizedString(@"whats.new.button.title", nil);
    if ([button length] == 0 && [self shouldShowAsDebug]) {
        button = NSLocalizedString(@"whats.new.button.title.debug", nil);
    }
    return button;
}

- (HEMWhatsNewLocation)location {
    return HEMWhatsNewLocationSettings;
}

@end
