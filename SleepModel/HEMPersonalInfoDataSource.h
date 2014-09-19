//
//  HEMPersonalInfoDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 9/18/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SenseKit/SENAccount.h>

typedef NS_ENUM(NSUInteger, HEMPersonalInfo) {
    HEMPersonalInfoBirthdate = 0,
    HEMPersonalInfoGender = 1,
    HEMPersonalInfoHeight = 2,
    HEMPersonalInfoWeight = 3
};

@interface HEMPersonalInfoDataSource : NSObject <UITableViewDataSource>

- (NSString*)tableView:(UITableView*)tableView titleForIndexPath:(NSIndexPath*)indexPath;
- (NSString*)tableView:(UITableView*)tableView subtitleForIndexPath:(NSIndexPath*)indexPath;
- (void)refresh:(void(^)(void))completion;
- (BOOL)isLoaded;

- (NSDateComponents*)birthdateComponents;
- (NSInteger)heightInInches;
- (NSInteger)weightInLbs;
- (SENAccountGender)gender;

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(void))completion;
- (void)updateHeight:(int)heightInCentimeters completion:(void(^)(void))completion;
- (void)updateWeight:(float)weightInKgs completion:(void(^)(void))completion;
- (void)updateGender:(SENAccountGender)gender completion:(void(^)(void))completion;

@end
