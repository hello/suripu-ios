//
//  HEMSettingsAccountDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMSettingsAcctSection) {
    HEMSettingsAcctSectionAccount = 0,      HEMSettingsAcctAccountTotRows = 3,
    HEMSettingsAcctSectionDemographics = 1, HEMSettingsAcctDemographicsTotRows = 4,
    HEMSettingsAcctSectionPreferences = 2,  HEMSettingsAcctPreferenceTotRows = 2,
    HEMSettingsacctSectionAudioExplanation = 3, HEMSettingsAcctAudioExplationTotRows = 1,
    HEMSettingsAcctSectionSignOut = 4,      HEMSettingsAcctSignOutTotRows = 1,
    HEMSettingsAcctTotalSections = 5 // increment when sections added
};

typedef NS_ENUM(NSUInteger, HEMSettingsAccountInfoType) {
    HEMSettingsAccountInfoTypeName,
    HEMSettingsAccountInfoTypeEmail,
    HEMSettingsAccountInfoTypePassword,
    HEMSettingsAccountInfoTypeBirthday,
    HEMSettingsAccountInfoTypeGender,
    HEMSettingsAccountInfoTypeHeight,
    HEMSettingsAccountInfoTypeWeight,
    HEMSettingsAccountInfoTypeEnhancedAudio,
    HEMSettingsAccountInfoTypeHealthKit,
    HEMSettingsAccountInfoTypeAudioExplanation,
    HEMSettingsAccountInfoTypeSignOut
};

typedef NS_ENUM(NSUInteger, HEMSettingsAccountError) {
    HEMSettingsAccountErrorInvalidArg,
    HEMSettingsAccountErrorAuthorizationRequired,
    HEMSettingsAccountErrorNotSupported
};

@interface HEMSettingsAccountDataSource : NSObject <UITableViewDataSource>

@property (assign, nonatomic, readonly, getter=isRefreshing) BOOL refreshing;

- (instancetype)initWithTableView:(UITableView*)tableView;
- (void)reload:(void(^)(NSError* error))completion;
- (HEMSettingsAccountInfoType)infoTypeAtIndexPath:(NSIndexPath*)indexPath;
- (UIImage*)iconImageForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)valueForInfoType:(HEMSettingsAccountInfoType)type;
- (NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isEnabledAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isTypeEnabled:(HEMSettingsAccountInfoType)type;
- (NSDateComponents*)birthdateComponents;
- (NSUInteger)genderEnumValue;
- (NSNumber*)heightInCm;
- (NSNumber*)weightInGrams;

#pragma mark - Updates

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(NSError* error))completion;

- (void)updateHeight:(CGFloat)heightInCentimeters
          completion:(void(^)(NSError* error))completion;

- (void)updateWeight:(CGFloat)grams
          completion:(void(^)(NSError* error))completion;

- (void)updateGender:(SENAccountGender)gender
          completion:(void(^)(NSError* error))completion;

- (void)updateName:(NSString*)name completion:(void(^)(NSError* error))completion;
- (void)updateEmail:(NSString*)email completion:(void(^)(NSError* error))completion;
- (void)updatePassword:(NSString*)password
       currentPassword:(NSString*)currentPassword
            completion:(void(^)(NSError* error))completion;

- (void)enablePreference:(BOOL)enable
                 forType:(HEMSettingsAccountInfoType)type
              completion:(void(^)(NSError* error))completion;

@end
