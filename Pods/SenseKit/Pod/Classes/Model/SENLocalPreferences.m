//
//  SENLocalPreferences.m
//  Pods
//
//  Created by Jimmy Lu on 2/19/15.

#import "SENLocalPreferences.h"
#import "SENAuthorizationService.h"

// need to keep the value as is since it has been used already
NSString* const SENLocalPrefAppGroup = @"group.is.hello.sense.settings";
NSString* const SENLocalPrefDidChangeNotification = @"SENLocalPrefDidChangeNotification";

static NSString* const SENLocalPreferenceSessionKey = @"$session";
static NSString* const SENLocalPreferenceUserKey = @"$user";

@interface SENLocalPreferences()

@property (nonatomic, strong) NSUserDefaults* defaults;

@end

@implementation SENLocalPreferences

+ (instancetype)sharedPreferences {
    static SENLocalPreferences* preferences = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferences = [[super allocWithZone:NULL] initWithGroup:SENLocalPrefAppGroup];
    });
    return preferences;
}

- (instancetype)initWithGroup:(NSString*)group {
    self = [super init];
    if (self) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:group];
    }
    return self;
}

- (id)init {
    return [self initWithGroup:SENLocalPrefAppGroup];
}

- (void)removeSessionPreferences {
    [[self defaults] removeObjectForKey:SENLocalPreferenceSessionKey];
}

- (BOOL)setUserPreference:(id)preference forKey:(NSString*)key {
    NSString* userId = [SENAuthorizationService accountIdOfAuthorizedUser];
    
    if (key == nil || userId == nil) return NO;

    NSMutableDictionary* allPreferences = [[[self defaults] dictionaryForKey:SENLocalPreferenceUserKey] mutableCopy];
    if (allPreferences == nil) {
        allPreferences = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary* userPreferences = [[allPreferences objectForKey:userId] mutableCopy];
    if (userPreferences == nil) {
        userPreferences = [NSMutableDictionary dictionary];
    }
    
    // setValue: in dictionary will remove preference if nil
    [userPreferences setValue:preference forKey:key];
    [allPreferences setValue:userPreferences forKey:userId];
    [[self defaults] setObject:allPreferences forKey:SENLocalPreferenceUserKey];
    
    [[self defaults] synchronize];
    [self notifyChangeToKey:key];
    
    return YES;
}

- (id)userPreferenceForKey:(NSString*)key {
    NSString* userId = [SENAuthorizationService accountIdOfAuthorizedUser];
    
    if (key == nil || userId == nil) return nil;
    
    NSDictionary* allPreferences = [[self defaults] dictionaryForKey:SENLocalPreferenceUserKey];
    NSDictionary* userPreferences = [allPreferences objectForKey:userId];
    return [userPreferences objectForKey:key];
}

- (BOOL)setSessionPreference:(id)preference forKey:(NSString*)key {
    if (key == nil) return NO;
    
    NSMutableDictionary* transientPreferences = [[[self defaults] dictionaryForKey:SENLocalPreferenceSessionKey] mutableCopy];
    if (transientPreferences == nil) {
        transientPreferences = [NSMutableDictionary dictionary];
    }
    
    [transientPreferences setValue:preference forKey:key];
    [[self defaults] setObject:transientPreferences forKey:SENLocalPreferenceSessionKey];
    [self notifyChangeToKey:key];
    
    return YES;
}

- (id)sessionPreferenceForKey:(NSString*)key {
    if (key == nil) return nil;
    
    NSDictionary* transientPreferences = [[self defaults] dictionaryForKey:SENLocalPreferenceSessionKey];
    return [transientPreferences objectForKey:key];
}

- (void)setPersistentPreference:(id)preference forKey:(NSString*)key {
    if (preference == nil) {
        [[self defaults] removeObjectForKey:key];
    } else {
        [[self defaults] setObject:preference forKey:key];
    }
    [[self defaults] synchronize];
    [self notifyChangeToKey:key];
}

- (id)persistentPreferenceForKey:(NSString*)key {
    return [[self defaults] objectForKey:key];
}

- (void)notifyChangeToKey:(NSString*)key {
    [[NSNotificationCenter defaultCenter] postNotificationName:SENLocalPrefDidChangeNotification object:key];
}

@end