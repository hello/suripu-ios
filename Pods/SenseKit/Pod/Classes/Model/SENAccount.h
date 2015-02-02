//
//  SENAccount.h
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENAccountGender) {
    SENAccountGenderOther,
    SENAccountGenderMale,
    SENAccountGenderFemale
};

@interface SENAccount : NSObject

@property (nonatomic, copy, readonly)    NSString* accountId;

/**
 * @property lastModified
 * 
 * The date of which this account was last modified.  Required
 * when making additional updates after account creation
 */
@property (nonatomic, copy, readonly)    NSNumber* lastModified;

/**
 * @property name
 *
 * The name of the user that this account belongs to
 */
@property (nonatomic, copy, readwrite)   NSString* name;

/**
 * @property name
 *
 * The email address that the user wants to use.  Email address is
 * used for authentication as well.
 */
@property (nonatomic, copy, readwrite)   NSString* email;

/**
 * @property gender
 *
 * The gender of the user.  Defaults to SENAccountOther
 */
@property (nonatomic, assign, readwrite) SENAccountGender gender;

/**
 * @property weight
 *
 * The weight in grams of the user.
 */
@property (nonatomic, strong, readwrite) NSNumber* weight; // in grams

/**
 * @property height
 * 
 * The height in centimeters of the user
 */
@property (nonatomic, strong, readwrite) NSNumber* height; // in cm

/**
 * @property birthdate
 *
 * The birthdate in ISO date format yyyy-MM-dd of the user
 *
 */
@property (nonatomic, copy, readwrite)   NSString* birthdate;

/**
 * @property latitude
 *
 * The current latitude coordinate of the user used to determine
 * environmental conditions.
 */
@property (nonatomic, strong, readwrite) NSNumber* latitude;

/**
 * @property longitude
 *
 * The current longitude coordinate of the user used to determine
 * environmental conditions.
 */
@property (nonatomic, strong, readwrite) NSNumber* longitude;

/**
 * Initialize the SENAccount and return the instance with the specified
 * account id and and lastModifiedDate, which are both not changeable
 * on the client.
 *
 * @param accountId:      the unique identifier of the account
 * @param isoLateModDate: the last modified date of the account object in milli
 */
- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSNumber*)isoLastModDate;

/**
 * Set the birth date with individual components
 * @param month: month of the birth month where 1 = january
 * @param day:   day of the birthdate (1 - 31)
 * @param year:  year of birth (yyyy)
 */
- (void)setBirthMonth:(NSInteger)month day:(NSInteger)day andYear:(NSInteger)year;

/**
 * Set the birth date with the milliseconds from January 1, 1970 GMT
 * @param birthdateInMillis: milliseconds representing the birthdate since Jan 1, 1970
 */
- (void)setBirthdateInMillis:(NSNumber*)birthdateInMillis;

/**
 * Return the birthdate components, which will contain year, month, and day
 * if the birthdate is available
 * @return birthdate components
 */
- (NSDateComponents*)birthdateComponents;

/**
 * @return localized birthdate as NSString given the preferred date style
 */
- (NSString*)localizedBirthdateWithStyle:(NSDateFormatterStyle)style;

@end
