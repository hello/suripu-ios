//
//  HEMSettingsAccountDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 1/21/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMSettingsAccountInfoType) {
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
- (NSString*)titleForCellAtIndexPath:(NSIndexPath*)indexPath;
- (NSString*)valueForCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isEnabledAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isTypeEnabled:(HEMSettingsAccountInfoType)type;
- (BOOL)isLastRow:(NSIndexPath*)indexPath;
- (NSDateComponents*)birthdateComponents;
- (NSUInteger)genderEnumValue;
- (float)heightInInches;
- (float)weightInPounds;

#pragma mark - Updates

- (void)updateBirthMonth:(NSInteger)month
                     day:(NSInteger)day
                    year:(NSInteger)year
              completion:(void(^)(NSError* error))completion;

- (void)updateHeight:(int)heightInCentimeters
          completion:(void(^)(NSError* error))completion;

- (void)updateWeight:(float)weightInKgs
          completion:(void(^)(NSError* error))completion;

- (void)updateGender:(SENAccountGender)gender
          completion:(void(^)(NSError* error))completion;

- (void)enablePreference:(BOOL)enable
                 forType:(HEMSettingsAccountInfoType)type
              completion:(void(^)(NSError* error))completion;

@end
