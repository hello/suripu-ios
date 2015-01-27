//
//  HEMSettingsAccountDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENServiceHealthKit.h>
#import <SenseKit/Model.h>

#import "HEMSettingsAccountDataSource.h"
#import "HEMMathUtil.h"
#import "HEMMainStoryboard.h"
#import "HEMSettingsUtil.h"

// \u0222 is a round dot
static NSString* const HEMSettingsAcctPasswordPlaceholder = @"\u2022\u2022\u2022\u2022\u2022\u2022";
static NSString* const HEMSettingsAcctDataSourceErrorDomain = @"is.hello.app.settings.account";

static NSInteger const HEMSettingsAcctSectionAccount = 0;
static NSInteger const HEMSettingsAcctSectionDemographics = 1;
static NSInteger const HEMSettingsAcctSectionPreferences = 2;
static NSInteger const HEMSettingsAcctTotalSections = 3; // bump this if you add sections above

static NSInteger const HEMSettingsAcctRowEmail = 0;
static NSInteger const HEMSettingsAcctRowPassword = 1;
static NSInteger const HEMSettingsAcctAccountTotRows = 2;

static NSInteger const HEMSettingsAcctRowBirthdate = 0;
static NSInteger const HEMSettingsAcctRowGender = 1;
static NSInteger const HEMSettingsAcctRowHeight = 2;
static NSInteger const HEMSettingsAcctRowWeight = 3;
static NSInteger const HEMSettingsAcctDemographicsTotRows = 4;

static NSInteger const HEMSettingsAcctRowHealthKit = 0;
static NSInteger const HEMSettingsAcctRowEnhancedAudio = 1;
static NSInteger const HEMSettingsAcctPreferenceTotRows = 2;

@interface HEMSettingsAccountDataSource()

@property (assign, nonatomic, getter=isRefreshing) BOOL refreshing;
@property (weak,   nonatomic) UITableView* tableView;

@end

@implementation HEMSettingsAccountDataSource

- (instancetype)initWithTableView:(UITableView*)tableView {
    self = [super init];
    if (self) {
        _tableView = tableView;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return HEMSettingsAcctTotalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case HEMSettingsAcctSectionAccount:
            rows = HEMSettingsAcctAccountTotRows;
            break;
        case HEMSettingsAcctSectionDemographics:
            rows = HEMSettingsAcctDemographicsTotRows;
            break;
        case HEMSettingsAcctSectionPreferences:
            rows = HEMSettingsAcctPreferenceTotRows;
            break;
        default:
            break;
    }
    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = [indexPath section];
    NSString* reuseId = nil;
    
    if (section == HEMSettingsAcctSectionPreferences) {
        reuseId = [HEMMainStoryboard preferenceReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard infoReuseIdentifier];
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

#pragma mark - Data

- (void)reload:(void(^)(NSError* error))completion {
    [self setRefreshing:YES];

    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error == nil) {
            [strongSelf setRefreshing:NO];
            [[strongSelf tableView] reloadData];
        }
        
        if (completion) completion (error);
    }];
}

- (NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* title = nil;
    HEMSettingsAccountInfoType type = [self infoTypeAtIndexPath:indexPath];
    switch (type) {
        case HEMSettingsAccountInfoTypeEmail:
            title = NSLocalizedString(@"settings.account.email", nil);
            break;
        case HEMSettingsAccountInfoTypePassword:
            title = NSLocalizedString(@"settings.account.password", nil);
            break;
        case HEMSettingsAccountInfoTypeBirthday:
            title = NSLocalizedString(@"settings.personal.info.birthday", nil);
            break;
        case HEMSettingsAccountInfoTypeGender:
            title = NSLocalizedString(@"settings.personal.info.gender", nil);
            break;
        case HEMSettingsAccountInfoTypeHeight:
            title = NSLocalizedString(@"settings.personal.info.height", nil);
            break;
        case HEMSettingsAccountInfoTypeWeight:
            title = NSLocalizedString(@"settings.personal.info.weight", nil);
            break;
        case HEMSettingsAccountInfoTypeHealthKit:
            title = NSLocalizedString(@"settings.account.healthkit", nil);
            break;
        case HEMSettingsAccountInfoTypeEnhancedAudio:
            title = NSLocalizedString(@"settings.account.enhanced-audio", nil);
        default:
            break;
    }
    return title;
}

- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* subtitle = nil;
    HEMSettingsAccountInfoType type = [self infoTypeAtIndexPath:indexPath];
    switch (type) {
        case HEMSettingsAccountInfoTypeEmail:
            subtitle = [[[SENServiceAccount sharedService] account] email];
            break;
        case HEMSettingsAccountInfoTypePassword:
            subtitle = HEMSettingsAcctPasswordPlaceholder;
            break;
        case HEMSettingsAccountInfoTypeBirthday: {
            subtitle = [[[SENServiceAccount sharedService] account] birthdate];
            break;
        }
        case HEMSettingsAccountInfoTypeGender:
            subtitle = [self gender];
            break;
        case HEMSettingsAccountInfoTypeHeight:
            subtitle = [self height];
            break;
        case HEMSettingsAccountInfoTypeWeight:
            subtitle = [self weight];
            break;
        case HEMSettingsAccountInfoTypeHealthKit:
        case HEMSettingsAccountInfoTypeEnhancedAudio:
        default:
            break;
    }
    
    return subtitle ?: NSLocalizedString(@"empty-data", nil);
}

- (BOOL)isEnabledAtIndexPath:(NSIndexPath*)indexPath {
    HEMSettingsAccountInfoType type = [self infoTypeAtIndexPath:indexPath];
    return [self isTypeEnabled:type];
}

- (BOOL)isTypeEnabled:(HEMSettingsAccountInfoType)type {
    BOOL enabled = NO;
    switch (type) {
        case HEMSettingsAccountInfoTypeEnhancedAudio: {
            NSDictionary* prefs = [[SENServiceAccount sharedService] preferences];
            SENPreference* pref = [prefs objectForKey:@(SENPreferenceTypeEnhancedAudio)];
            enabled = [pref enabled];
            break;
        }
        case HEMSettingsAccountInfoTypeHealthKit: {
            enabled = [[SENServiceHealthKit sharedService] canWriteSleepAnalysis]
                        && [HEMSettingsUtil isHealthKitEnabled];
        }
        default:
            break;
    }
    return enabled;
}

- (NSDateComponents*)birthdateComponents {
    return [[[SENServiceAccount sharedService] account] birthdateComponents];
}

- (NSUInteger)genderEnumValue {
    return [[[SENServiceAccount sharedService] account] gender];
}

- (NSString*)gender {
    NSString* gender = nil;
    switch ([[[SENServiceAccount sharedService] account] gender]) {
        case SENAccountGenderFemale:
            gender = NSLocalizedString(@"account.gender.female", nil);
            break;
        case SENAccountGenderMale:
            gender = NSLocalizedString(@"account.gender.male", nil);
            break;
        default:
            break;
    }
    return gender;
}

- (float)heightInInches {
    return HEMToInches([[[SENServiceAccount sharedService] account] height]);
}

- (NSString*)height {
    NSNumber* cm = [[[SENServiceAccount sharedService] account] height];
    if (cm == nil) return nil;
    
    long cmValue = [cm longValue];
    NSString* height = nil;
    
    if (HEMIsMetricSystem()) {
        height = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cmValue];
    } else {
        long inValue = HEMToInches(cm);
        long feet = inValue / 12;
        long inches = inValue % 12;
        NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
        NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
        height = [NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat];
    }
    
    return height;
}

- (float)weightInPounds {
    return HEMToPounds([[[SENServiceAccount sharedService] account] weight]);
}

- (NSString*)weight {
    NSNumber* grams = [[[SENServiceAccount sharedService] account] weight];
    if (grams == nil) return nil;
    
    NSString* weight = nil;
    
    if (HEMIsMetricSystem()) {
        CGFloat gramValue = [grams floatValue];
        weight = [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), gramValue];
    } else {
        CGFloat pounds = HEMToPounds(grams);
        weight = [NSString stringWithFormat:NSLocalizedString(@"measurement.lb.format", nil), pounds];
    }
    
    return weight;
}

- (BOOL)isLastRow:(NSIndexPath*)indexPath {
    BOOL last = NO;
    switch ([indexPath section]) {
        case HEMSettingsAcctSectionAccount:
            last = [indexPath row] == HEMSettingsAcctAccountTotRows - 1;
            break;
        case HEMSettingsAcctSectionDemographics:
            last = [indexPath row] == HEMSettingsAcctDemographicsTotRows - 1;
            break;
        case HEMSettingsAcctSectionPreferences:
            last = [indexPath row] == HEMSettingsAcctPreferenceTotRows - 1;
            break;
        default:
            break;
    }
    return last;
}

- (HEMSettingsAccountInfoType)infoTypeAtIndexPath:(NSIndexPath*)indexPath {
    HEMSettingsAccountInfoType type = HEMSettingsAccountInfoTypeEmail;
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == HEMSettingsAcctSectionAccount) {
        switch (row) {
            case HEMSettingsAcctRowEmail:
                type = HEMSettingsAccountInfoTypeEmail;
                break;
            case HEMSettingsAcctRowPassword:
                type = HEMSettingsAccountInfoTypePassword;
                break;
            default:
                break;
        }
    } else if (section == HEMSettingsAcctSectionDemographics) {
        switch (row) {
            case HEMSettingsAcctRowBirthdate:
                type = HEMSettingsAccountInfoTypeBirthday;
                break;
            case HEMSettingsAcctRowGender:
                type = HEMSettingsAccountInfoTypeGender;
                break;
            case HEMSettingsAcctRowHeight:
                type = HEMSettingsAccountInfoTypeHeight;
                break;
            case HEMSettingsAcctRowWeight:
                type = HEMSettingsAccountInfoTypeWeight;
                break;
            default:
                break;
        }
    } else if (section == HEMSettingsAcctSectionPreferences) {
        switch (row) {
            case HEMSettingsAcctRowEnhancedAudio:
                type = HEMSettingsAccountInfoTypeEnhancedAudio;
                break;
            case HEMSettingsAcctRowHealthKit:
                type = HEMSettingsAccountInfoTypeHealthKit;
            default:
                break;
        }
    }
    return type;
}

#pragma mark - Updates

- (void)updateAccount:(void(^)(NSError* error))completion {
    [[self tableView] reloadData]; // reload first to reflect temp change
    
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] updateAccount:^(NSError *error) {
        [[weakSelf tableView] reloadData];
    }];
}

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(NSError* error))completion {
    __block SENAccount* account = [[SENServiceAccount sharedService] account];
    
    NSString* oldBirthdate = [account birthdate];
    [account setBirthMonth:month day:day andYear:year];

    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            [account setBirthdate:oldBirthdate];
        }
        if (completion) completion (error);
    }];
}

- (void)updateHeight:(int)heightInCentimeters completion:(void(^)(NSError* error))completion {
    __block SENAccount* account = [[SENServiceAccount sharedService] account];
    
    NSNumber* oldHeight = [account height];
    [account setHeight:@(heightInCentimeters)];

    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            [account setHeight:oldHeight];
        }
        if (completion) completion (error);
    }];
}

- (void)updateWeight:(float)weightInKgs completion:(void(^)(NSError* error))completion {
    __block SENAccount* account = [[SENServiceAccount sharedService] account];
    
    NSNumber* oldWeight = [account weight];
    [account setWeight:@(round(weightInKgs * 1000))];

    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            [account setWeight:oldWeight];
        }
        if (completion) completion (error);
    }];
}

- (void)updateGender:(SENAccountGender)gender completion:(void(^)(NSError* error))completion {
    __block SENAccount* account = [[SENServiceAccount sharedService] account];
    
    SENAccountGender oldGender = [account gender];
    [account setGender:gender];

    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            [account setGender:oldGender];
        }
        if (completion) completion (error);
    }];
}

#pragma mark Preferences

- (void)updatePreference:(SENPreference*)preference completion:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] updatePreference:preference completion:^(NSError *error) {
        [[weakSelf tableView] reloadData];
    }];
}

- (void)enablePreference:(BOOL)enable
                 forType:(HEMSettingsAccountInfoType)type
              completion:(void(^)(NSError* error))completion {

    switch (type) {
        case HEMSettingsAccountInfoTypeEnhancedAudio: {
            SENServiceAccount* service = [SENServiceAccount sharedService];
            SENPreference* preference = [[service preferences] objectForKey:@(SENPreferenceTypeEnhancedAudio)];
            [preference setEnabled:enable];
            [self updatePreference:preference completion:^(NSError *error) {
                if (error != nil) {
                    [preference setEnabled:!enable];
                }
                if (completion) completion (error);
            }];
            break;
        }
        case HEMSettingsAccountInfoTypeHealthKit: {
            [self enableHealthKit:enable completion:completion];
            break;
        }
        default: {
            if (completion) completion ([NSError errorWithDomain:HEMSettingsAcctDataSourceErrorDomain
                                                            code:-1
                                                        userInfo:nil]);
            break;
        }
    }
}

- (void)enableHealthKit:(BOOL)enable completion:(void(^)(NSError* error))completion {
    if (enable) {
        SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
        if (![service isSupported]) {
            if (completion) {
                completion ([NSError errorWithDomain:HEMSettingsAcctDataSourceErrorDomain
                                                code:HEMSettingsAccountErrorNotSupported
                                            userInfo:nil]);
            }
        } else {
            [service requestAuthorization:^(NSError *error) {
                if (error == nil) {
                    [HEMSettingsUtil enableHealthKit:enable];
                    [service setEnableWrite:enable];
                }
                if (completion) completion (error);
            }];
        }
    } else {
        [HEMSettingsUtil enableHealthKit:enable];
        [[SENServiceHealthKit sharedService] setEnableWrite:enable];
    }
}

@end
