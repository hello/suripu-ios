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

/**
 * Obtain the title text to use for the personal information cell for the specified
 * index path.
 * @param tableView: the tableview that the cell is contained in
 * @param indexPath: the index path of the cell
 * @return title:    title for the cell
 */
- (NSString*)tableView:(UITableView*)tableView titleForIndexPath:(NSIndexPath*)indexPath;

/**
 * Obtain the info for the particular index path within the tableview specified
 * @param tableView: the tableview that the cell is contained in
 * @param indexPath: the index path of the cell
 * @return the info for the particular index path
 */
- (NSString*)tableView:(UITableView*)tableView infoForIndexPath:(NSIndexPath*)indexPath;

/**
 * Refresh the information
 * @param completion: the completion block to invoke
 */
- (void)refresh:(void(^)(void))completion;

/**
 * @return YES if the data is ready and loaded.  NO otherwise
 */
- (BOOL)isLoaded;

/**
 * Return the year, month, and day from the user's account information, if it
 * has been loaded and if the birthdate was set
 * @return components of the birthdate
 */
- (NSDateComponents*)birthdateComponents;

/**
 * @return the height of the user's account in inches
 */
- (NSInteger)heightInInches;

/**
 * @return the weight of the user's account in pounds
 */
- (NSInteger)weightInLbs;

/**
 * @return the gender of the user
 */
- (SENAccountGender)gender;

#pragma mark - Updates -

/**
 * Update the user's birth month, day and year
 * @param month:      the user's birth month where 1 is January
 * @param day:        the day of the user's birthdate
 * @param year:       the year of the user's birthdate.  ex: 1970
 * @param completion: the completion block to invoke
 */
- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(NSError* error))completion;

/**
 * Update the user's height in centimeters
 * @param heightInCentimeters: height in centimeters
 * @param completion:          the completion block to invoke when done
 */
- (void)updateHeight:(int)heightInCentimeters completion:(void(^)(NSError* error))completion;

/**
 * Update the user's weight in kilograms
 * @param weightInKgs: weight of the user in kilograms
 * @param completion:  the completion block to invoke when done
 */
- (void)updateWeight:(float)weightInKgs completion:(void(^)(NSError* error))completion;

/**
 * Update the user's gender
 * @param gender:     the gender of the user
 * @param completion: the completion block to invoke when done
 */
- (void)updateGender:(SENAccountGender)gender completion:(void(^)(NSError* error))completion;

@end
