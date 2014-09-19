//
//  HEMPersonalInfoDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAccount.h>
#import <SenseKit/SENAPIAccount.h>

#import "HEMPersonalInfoDataSource.h"
#import "HEMMathUtil.h"

@interface HEMPersonalInfoDataSource()

@property (nonatomic, strong) SENAccount* account;

@end

@implementation HEMPersonalInfoDataSource

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"info";
    return [tableView dequeueReusableCellWithIdentifier:cellId]; // prototype cell
}

#pragma mark - Private Helpers

- (NSString*)genderFromAccount {
    NSString* gender = nil;
    switch ([[self account] gender]) {
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

- (NSString*)heightFromAccount {
    NSNumber* cm = [[self account] height];
    long cmValue = [cm longValue];
    NSString* height = nil;
    
    if (IsMetricSystem()) {
        height = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cmValue];
    } else {
        long inValue = ToInches(cm);
        long feet = floorf(inValue / 12);
        long inches = ceilf(inValue - (feet * 12));
        NSString* feetFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.ft.format", nil), (long)feet];
        NSString* inchFormat = [NSString stringWithFormat:NSLocalizedString(@"measurement.in.format", nil), (long)inches];
        height = [NSString stringWithFormat:@"%@ %@", feetFormat, inchFormat];
    }
    
    return height;
}

- (NSString*)weightFromAccount {
    NSNumber* grams = [[self account] weight];
    NSString* weight = nil;
    
    if (IsMetricSystem()) {
        long gramValue = [grams longValue];
        weight = [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), gramValue];
    } else {
        long pounds = ToPounds(grams);
        weight = [NSString stringWithFormat:NSLocalizedString(@"measurement.lb.format", nil), pounds];
    }
    
    return weight;
}

#pragma mark -

- (BOOL)isLoaded {
    return [self account] != nil;
}

- (NSString*)tableView:(UITableView*)tableView titleForIndexPath:(NSIndexPath*)indexPath {
    NSString* title = nil;
    switch ([indexPath row]) {
        case HEMPersonalInfoBirthdate: {
            title = NSLocalizedString(@"settings.personal.info.birthday", nil);
            break;
        }
        case HEMPersonalInfoGender: {
            title = NSLocalizedString(@"settings.personal.info.gender", nil);
            break;
        }
        case HEMPersonalInfoHeight: {
            title = NSLocalizedString(@"settings.personal.info.height", nil);
            break;
        }
        case HEMPersonalInfoWeight: {
            title = NSLocalizedString(@"settings.personal.info.weight", nil);
            break;
        }
        default:
            break;
    }
    return title;
}

- (NSString*)tableView:(UITableView*)tableView subtitleForIndexPath:(NSIndexPath*)indexPath {
    NSString* subtitle = nil;
    switch ([indexPath row]) {
        case HEMPersonalInfoBirthdate: {
            subtitle = [[self account] birthdate];
            break;
        }
        case HEMPersonalInfoGender: {
            subtitle = [self genderFromAccount];
            break;
        }
        case HEMPersonalInfoHeight: {
            subtitle = [self heightFromAccount];
            break;
        }
        case HEMPersonalInfoWeight: {
            subtitle = [self weightFromAccount];
            break;
        }
        default:
            break;
    }
    return subtitle;
}

- (void)refresh:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccount:^(SENAccount* account, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && account != nil) {
            [strongSelf setAccount:account];
        }
        if (completion) completion();
    }];
}

- (NSDateComponents*)birthdateComponents {
    return [[self account] birthdateComponents];
}

- (NSInteger)heightInInches {
    return ToInches([[self account] height]);
}

- (NSInteger)weightInLbs {
    return ToPounds([[self account] weight]);
}

- (SENAccountGender)gender {
    return [[self account] gender];
}

#pragma mark - Updates

- (void)updateAccount:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount updateAccount:[self account] completionBlock:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf refresh:completion];
        }
    }];
}

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(void))completion {
    [[self account] setBirthMonth:month day:day andYear:year];
    [self updateAccount:completion];
}

- (void)updateHeight:(int)heightInCentimeters completion:(void(^)(void))completion {
    [[self account] setHeight:@(heightInCentimeters)];
    [self updateAccount:completion];
}

- (void)updateWeight:(float)weightInKgs completion:(void(^)(void))completion {
    [[self account] setWeight:@(ceilf(weightInKgs * 1000))];
    [self updateAccount:completion];
}

- (void)updateGender:(SENAccountGender)gender completion:(void(^)(void))completion {
    [[self account] setGender:gender];
    [self updateAccount:completion];
}

@end
