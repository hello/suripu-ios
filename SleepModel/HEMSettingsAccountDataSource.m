//
//  HEMSettingsAccountDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <SenseKit/SENServiceAccount.h>
#import <SenseKit/SENAccount.h>

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

- (void)reload {
    [self setRefreshing:YES];

    __weak typeof(self) weakSelf = self;
    [[SENServiceAccount sharedService] refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            [strongSelf setRefreshing:NO];
            [[strongSelf tableView] reloadData];
        }
    }];
}

- (NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* title = nil;
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section == HEMSettingsAcctSectionAccount) {
        switch (row) {
            default:
            case HEMSettingsAcctRowEmail:
                title = NSLocalizedString(@"settings.account.email", nil);
                break;
            case HEMSettingsAcctRowPassword:
                title = NSLocalizedString(@"settings.account.password", nil);
                break;
        }
    } else if (section == HEMSettingsAcctSectionDemographics) {
        switch (row) {
            case HEMSettingsAcctRowBirthdate:
                title = NSLocalizedString(@"settings.personal.info.birthday", nil);
                break;
            case HEMSettingsAcctRowGender:
                title = NSLocalizedString(@"settings.personal.info.gender", nil);
                break;
            case HEMSettingsAcctRowHeight:
                title = NSLocalizedString(@"settings.personal.info.height", nil);
                break;
            case HEMSettingsAcctRowWeight:
                title = NSLocalizedString(@"settings.personal.info.weight", nil);
                break;
            default:
                break;
        }
    }
    return title;
}

- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath {
    NSString* subtitle = nil;
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    if (section == HEMSettingsAcctSectionAccount) {
        switch (row) {
            case HEMSettingsAcctRowEmail:
                subtitle = [[[SENServiceAccount sharedService] account] email];
                break;
            case HEMSettingsAcctRowPassword:
                subtitle = HEMSettingsAcctPasswordPlaceholder;
                break;
            default:
                break;
        }
    } else if (section == HEMSettingsAcctSectionDemographics) {
        switch (row) {
            case HEMSettingsAcctRowBirthdate:
                subtitle = [[[SENServiceAccount sharedService] account] birthdate];
                break;
            case HEMSettingsAcctRowGender:
                subtitle = [self gender];
                break;
            case HEMSettingsAcctRowHeight:
                subtitle = [self height];
                break;
            case HEMSettingsAcctRowWeight:
                subtitle = [self weight];
                break;
            default:
                break;
        }
    }
    return subtitle;
}

- (NSDateComponents*)birthdateComponents {
    return [[[SENServiceAccount sharedService] account] birthdateComponents];
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
            gender = NSLocalizedString(@"account.gender.other", nil);
            break;
    }
    return gender;
}

- (NSString*)height {
    NSNumber* cm = [[[SENServiceAccount sharedService] account] height];
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

- (NSString*)weight {
    NSNumber* grams = [[[SENServiceAccount sharedService] account] weight];
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

@end
