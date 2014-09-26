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
#import "HEMMainStoryboard.h"

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
    NSString* reuseId = [HEMMainStoryboard infoReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId]; // prototype cell
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
    
    if (HEMIsMetricSystem()) {
        height = [NSString stringWithFormat:NSLocalizedString(@"measurement.cm.format", nil), (long)cmValue];
    } else {
        long inValue = HEMToInches(cm);
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
    
    if (HEMIsMetricSystem()) {
        long gramValue = [grams longValue];
        weight = [NSString stringWithFormat:NSLocalizedString(@"measurement.kg.format", nil), gramValue];
    } else {
        long pounds = HEMToPounds(grams);
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

- (NSString*)tableView:(UITableView*)tableView infoForIndexPath:(NSIndexPath*)indexPath {
    NSString* info = nil;
    switch ([indexPath row]) {
        case HEMPersonalInfoBirthdate: {
            info = [[self account] birthdate];
            break;
        }
        case HEMPersonalInfoGender: {
            info = [self genderFromAccount];
            break;
        }
        case HEMPersonalInfoHeight: {
            info = [self heightFromAccount];
            break;
        }
        case HEMPersonalInfoWeight: {
            info = [self weightFromAccount];
            break;
        }
        default:
            break;
    }
    return info;
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
    return HEMToInches([[self account] height]);
}

- (NSInteger)weightInLbs {
    return HEMToPounds([[self account] weight]);
}

- (SENAccountGender)gender {
    return [[self account] gender];
}

#pragma mark - Updates

- (void)updateAccount:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount updateAccount:[self account] completionBlock:^(id data, NSError *error) {
        if (error != nil) {
            if (completion) completion (error);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf refresh:^{
                if (completion) completion(nil);
            }];
        }
    }];
}

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(NSError* error))completion {
    NSString* oldBirthdate = [[self account] birthdate];
    
    [[self account] setBirthMonth:month day:day andYear:year];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf account] setBirthdate:oldBirthdate];
            }
        }
        if (completion) completion (error);
    }];
}

- (void)updateHeight:(int)heightInCentimeters completion:(void(^)(NSError* error))completion {
    NSNumber* oldHeight = [[self account] height];
    
    [[self account] setHeight:@(heightInCentimeters)];

    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf account] setHeight:oldHeight];
            }
        }
        if (completion) completion (error);
    }];
}

- (void)updateWeight:(float)weightInKgs completion:(void(^)(NSError* error))completion {
    NSNumber* oldWeight = [[self account] weight];
    
    [[self account] setWeight:@(ceilf(weightInKgs * 1000))];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf account] setWeight:oldWeight];
            }
        }
        if (completion) completion (error);
    }];
}

- (void)updateGender:(SENAccountGender)gender completion:(void(^)(NSError* error))completion {
    SENAccountGender oldGender = [[self account] gender];
    
    [[self account] setGender:gender];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        if (error != nil) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [[strongSelf account] setGender:oldGender];
            }
        }
        if (completion) completion (error);
    }];
}

@end
