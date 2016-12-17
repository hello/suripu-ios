//
//  HEMBreadcrumbService.m
//  Sense
//
//  Created by Jimmy Lu on 5/26/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENLocalPreferences.h>
#import <SenseKit/SENAccount.h>

#import "NSDate+HEMRelative.h"

#import "HEMBreadcrumbService.h"

NSString* const HEMBreadcrumbSettings = @"settings";
NSString* const HEMBreadcrumbAccount = @"account";

static NSString* const HEMBreadcrumbPreferenceKey = @"HEMBreadcrumbPreferenceKey";

@interface HEMBreadcrumbService()

@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<NSString*>*>* crumbsPerAccount;
@property (nonatomic, strong) SENAccount* account;

@end

@implementation HEMBreadcrumbService

+ (instancetype)sharedServiceForAccount:(SENAccount*)account {
    static HEMBreadcrumbService* shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        shared = [HEMBreadcrumbService new];
    });
    if (account && ![[[shared account] accountId] isEqualToString:[account accountId]]) {
        [shared setAccount:account];
        [shared loadCrumbs];
    }
    return shared;
}

- (void)loadCrumbs {
    SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
    NSDictionary* savedCrumbs = [prefs userPreferenceForKey:HEMBreadcrumbPreferenceKey];
    
    if (savedCrumbs) {
        [self setCrumbsPerAccount:[savedCrumbs mutableCopy]];
    } else {
        [self setCrumbsPerAccount:[NSMutableDictionary dictionaryWithCapacity:1]];
    }
}

- (void)saveCrumbs {
    if ([self crumbsPerAccount]) {
        SENLocalPreferences* prefs = [SENLocalPreferences sharedPreferences];
        [prefs setUserPreference:[self crumbsPerAccount] forKey:HEMBreadcrumbPreferenceKey];
    }
}

- (NSString*)peek {
    NSString* accountId = [[self account] accountId];
    if (!accountId) {
        return nil;
    }
    return [[self crumbsPerAccount][accountId] lastObject]; // top is last
}

- (NSString*)pop {
    NSString* accountId = [[self account] accountId];
    if (!accountId) {
        return nil;
    }
    NSArray* crumbs = [self crumbsPerAccount][accountId];
    NSString* startCrumb = [crumbs lastObject];

    if (startCrumb) {
        NSMutableArray* updatedCrumbs = [crumbs mutableCopy];
        [updatedCrumbs removeLastObject];
        [self crumbsPerAccount][accountId] = updatedCrumbs;
        [self saveCrumbs];
    }
    
    return startCrumb;
}

- (BOOL)clearIfTrailEndsAt:(NSString*)crumb {
    NSString* accountId = [[self account] accountId];
    if (!accountId) {
        return NO;
    }
    
    BOOL cleared = NO;
    
    NSArray* crumbs = [self crumbsPerAccount][accountId];
    NSString* lastCrumb = [crumbs firstObject];
    if ([lastCrumb isEqualToString:crumb]) {
        [self crumbsPerAccount][accountId] = @[];
        [self saveCrumbs];
        cleared = YES;
    }
    
    return cleared;
}

@end
