//
//  HEMAccountService.h
//  Sense
//
//  Created by Jimmy Lu on 12/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "SENService.h"
#import "SENPreference.h"

@class SENAccount;

typedef struct {
    CGFloat feet;
    CGFloat inches;
    CGFloat centimeters;
} HEMAccountHeight;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const HEMAccountServiceDomain;

typedef NS_ENUM(NSInteger, HEMAccountServiceError) {
    HEMAccountServiceErrorUnknown = 0,
    HEMAccountServiceErrorInvalidArg = -1,
    HEMAccountServiceErrorPasswordNotRecognized = -2,
    HEMAccountServiceErrorAccountNotUpToDate = -3,
    HEMAccountServiceErrorNameTooShort = -4,
    HEMAccountServiceErrorNameTooLong = -5,
    HEMAccountServiceErrorEmailInvalid = -6,
    HEMAccountServiceErrorPasswordInsecure = -7,
    HEMAccountServiceErrorPasswordTooShort = -8,
    HEMAccountServiceErrorEmailAlreadyExists = -9,
    HEMAccountServiceErrorServerFailure = -10,
    HEMAccountServiceErrorNoAccount = -11
};

typedef void(^HEMAccountHandler)(SENAccount* account, NSDictionary<NSNumber*, SENPreference*>* preferences);
typedef void(^HEMAccountUpdateHandler)(NSError* _Nullable error);

@interface HEMAccountService : SENService

@property (nonatomic, strong, readonly, nullable) SENAccount* account;

+ (instancetype)sharedService;

- (void)refresh:(HEMAccountHandler)completion;
- (BOOL)isEnabled:(SENPreferenceType)preferenceType;
- (void)enablePreference:(BOOL)enable
                 forType:(SENPreferenceType)type
              completion:(nullable HEMAccountUpdateHandler)completion;
- (NSString*)localizedHeightInPreferredUnit;
- (NSString*)localizedWeightInPreferredUnit;

- (void)updateBirthdate:(NSString*)birthdate completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updateGender:(SENAccountGender)gender completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updateHeight:(NSNumber*)height completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updateWeight:(NSNumber*)weight completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updateName:(NSString*)name completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updateEmail:(NSString*)email completion:(nullable HEMAccountUpdateHandler)completion;
- (void)updatePassword:(NSString*)currentPassword
           newPassword:(NSString*)newPassword
            completion:(nullable HEMAccountUpdateHandler)completion;

@end

NS_ASSUME_NONNULL_END
