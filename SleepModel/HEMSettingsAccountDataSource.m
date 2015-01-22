//
//  HEMSettingsAccountDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENAPIAccount.h>

#import "HEMSettingsAccountDataSource.h"
#import "HEMMathUtil.h"

static NSString* const HEMSettingsAcctCellReuseId = @"info";
static NSString* const HEMSettingsAcctPasswordPlaceholder = @"\u2022\u2022\u2022\u2022\u2022\u2022";

static NSInteger const HEMSettingsAcctSectionAccount = 0;
static NSInteger const HEMSettingsAcctSectionDemographics = 1;
static NSInteger const HEMSettingsAcctTotalSections = 2; // bump this if you add sections above

static NSInteger const HEMSettingsAcctRowEmail = 0;
static NSInteger const HEMSettingsAcctRowPassword = 1;
static NSInteger const HEMSettingsAcctAccountTotRows = 2;

static NSInteger const HEMSettingsAcctRowBirthdate = 0;
static NSInteger const HEMSettingsAcctRowGender = 1;
static NSInteger const HEMSettingsAcctRowHeight = 2;
static NSInteger const HEMSettingsAcctRowWeight = 3;
static NSInteger const HEMSettingsAcctDemographicsTotRows = 4;

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
        default:
            break;
    }
    return rows;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:HEMSettingsAcctCellReuseId];
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
        default:
            break;
    }
    return title;
}

- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath {
    if ([self isRefreshing]) return NSLocalizedString(@"empty-data", nil);
    
    NSString* subtitle = nil;
    HEMSettingsAccountInfoType type = [self infoTypeAtIndexPath:indexPath];
    switch (type) {
        case HEMSettingsAccountInfoTypeEmail:
            subtitle = [[[SENServiceAccount sharedService] account] email];
            break;
        case HEMSettingsAccountInfoTypePassword:
            subtitle = HEMSettingsAcctPasswordPlaceholder;
            break;
        case HEMSettingsAccountInfoTypeBirthday:
            subtitle = [[[SENServiceAccount sharedService] account] birthdate];
            break;
        case HEMSettingsAccountInfoTypeGender:
            subtitle = [self gender];
            break;
        case HEMSettingsAccountInfoTypeHeight:
            subtitle = [self height];
            break;
        case HEMSettingsAccountInfoTypeWeight:
            subtitle = [self weight];
            break;
        default:
            break;
    }
    return subtitle;
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
            gender = NSLocalizedString(@"empty-data", nil);
            break;
    }
    return gender;
}

- (float)heightInInches {
    return HEMToInches([[[SENServiceAccount sharedService] account] height]);
}

- (NSString*)height {
    NSNumber* cm = [[[SENServiceAccount sharedService] account] height];
    if (cm == nil) {
        return NSLocalizedString(@"empty-data", nil);
    }
    
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
    if (grams == nil) {
        return NSLocalizedString(@"empty-data", nil);
    }
    
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
    }
    return type;
}

#pragma mark - Updates

- (void)updateAccount:(void(^)(NSError* error))completion {
    [[self tableView] reloadData]; // reload first to reflect temp change
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount updateAccount:[[SENServiceAccount sharedService] account] completionBlock:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            [strongSelf reload:completion];
            return;
        }
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

@end
