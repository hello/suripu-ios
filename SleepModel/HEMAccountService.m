//
//  HEMAccountService.m
//  Sense
//
//  Created by Jimmy Lu on 12/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import <AFNetworking/AFNetworking.h>
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/SENAPIAccount.h>
#import <SenseKit/SENAPIPreferences.h>
#import <SenseKit/SENAPIPhoto.h>
#import <SenseKit/SENPreference.h>
#import <SenseKit/SENAccount.h>

#import "HEMAccountService.h"
#import "HEMMathUtil.h"
#import "NSString+HEMUtils.h"

NSString* const HEMAccountServiceNotificationDidRefresh = @"HEMAccountServiceNotificationDidRefresh";
NSString* const HEMAccountServiceDomain = @"is.hello.app.account";
CGFloat const HEMAccountPhotoDefaultCompression = 0.8f;

@interface HEMAccountService()

@property (nonatomic, strong) SENAccount* account;
@property (nonatomic, strong) NSDictionary* preferences;

@end

@implementation HEMAccountService

+ (instancetype)sharedService {
    static HEMAccountService* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [super new];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self listenForAuthChanges];
    }
    return self;
}

- (NSError*)errorWithCode:(HEMAccountServiceError)code {
    return [NSError errorWithDomain:HEMAccountServiceDomain code:code userInfo:nil];
}

#pragma mark - API

- (NSError*)commonServiceErrorFromAPIError:(NSError*)error unrecognizedStatusCode:(NSInteger*)statusCode {
    SENAPIAccountError accountError = [SENAPIAccount errorForAPIResponseError:error];
    switch (accountError) {
        case SENAPIAccountErrorInvalidArgument:
            return [self errorWithCode:HEMAccountServiceErrorInvalidArg];
        case SENAPIAccountErrorNameTooShort:
            return [self errorWithCode:HEMAccountServiceErrorNameTooShort];
        case SENAPIAccountErrorEmailInvalid:
            return [self errorWithCode:HEMAccountServiceErrorEmailInvalid];
        case SENAPIAccountErrorNameTooLong:
            return [self errorWithCode:HEMAccountServiceErrorNameTooLong];
        case SENAPIAccountErrorPasswordInsecure:
            return [self errorWithCode:HEMAccountServiceErrorPasswordInsecure];
        case SENAPIAccountErrorPasswordTooShort:
            return [self errorWithCode:HEMAccountServiceErrorPasswordTooShort];
        case SENAPIAccountErrorUnknown:
        default: {
            NSHTTPURLResponse* response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
            switch ([response statusCode]) {
                case 412:
                    return [self errorWithCode:HEMAccountServiceErrorAccountNotUpToDate];
                case 500:
                    return [self errorWithCode:HEMAccountServiceErrorServerFailure];
                default:
                    if (statusCode != NULL) {
                        *statusCode = [response statusCode];
                    }
                    return nil;
            }
        }
    }
}

- (NSError*)translateEmailUpdateAPIError:(NSError*)error {
    NSInteger unrecognizedCode = 0;
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:&unrecognizedCode];
    
    if (!serviceError) {
        switch (unrecognizedCode) {
            case 409:
                serviceError = [self errorWithCode:HEMAccountServiceErrorEmailAlreadyExists];
                break;
            default:
                serviceError = error; // pass error through since it can't be interpreted here
                break;
        }
    }
    
    return serviceError;
}

- (NSError*)translatePasswordUpdateAPIError:(NSError*)error {
    NSInteger unrecognizedCode = 0;
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:&unrecognizedCode];
    
    if (!serviceError) {
        switch (unrecognizedCode) {
            case 409:
                serviceError = [self errorWithCode:HEMAccountServiceErrorPasswordNotRecognized];
                break;
            default:
                serviceError = error; // pass error through since it can't be interpreted here
                break;
        }
    }
    
    return serviceError;
}

- (NSError*)translateUpdateAPIError:(NSError*)error {
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:nil];
    return serviceError ?: error;
}

- (void)updateAccountWithPhoto:(BOOL)photo completion:(void(^)(void))completion {
    NSDictionary* queryParams = nil;
    if (photo) {
        queryParams = @{SENAPIAccountQueryParamPhoto : @"true"};
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccountWithQuery:queryParams completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf setAccount:data];
        }
        completion();
    }];
}

- (void)refreshWithPhoto:(BOOL)photo completion:(HEMAccountHandler)completion {
    __weak typeof(self) weakSelf = self;
    dispatch_group_t updateGroup = dispatch_group_create();
    
    dispatch_group_enter(updateGroup);
    [self updateAccountWithPhoto:photo completion:^{
        dispatch_group_leave(updateGroup);
    }];
    
    dispatch_group_enter(updateGroup);
    [SENAPIPreferences getPreferences:^(NSDictionary* data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [[data allValues] makeObjectsPerformSelector:@selector(saveLocally)];
            [weakSelf setPreferences:data];
        }
        dispatch_group_leave(updateGroup);
    }];
    
    dispatch_group_notify(updateGroup, dispatch_get_main_queue(), ^{
        completion ([weakSelf account], [weakSelf preferences]);
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:HEMAccountServiceNotificationDidRefresh object:nil];
    });
}

- (void)refresh:(HEMAccountHandler)completion {
    [self refreshWithPhoto:NO completion:completion];
}

#pragma mark Updates

- (void)updateAccount:(HEMAccountUpdateHandler)completion {
    if (![self account]) {
        completion ([self errorWithCode:HEMAccountServiceErrorNoAccount]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount updateAccount:[self account] completionBlock:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error) {
            if ([data isKindOfClass:[SENAccount class]]) {
                [strongSelf setAccount:data];
            }
        }
        completion (error);
    }];
}

- (void)updateBirthdate:(NSString*)birthdate completion:(nullable HEMAccountUpdateHandler)completion {
    NSString* oldBirthdate = [[self account] birthdate];
    [[self account] setBirthdate:birthdate];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        NSError* serviceError = [weakSelf translateUpdateAPIError:error];
        if (serviceError) {
            [[weakSelf account] setBirthdate:oldBirthdate];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    }];
}

- (void)updateGender:(SENAccountGender)gender completion:(nullable HEMAccountUpdateHandler)completion {
    SENAccountGender oldGender = [[self account] gender];
    [[self account] setGender:gender];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        NSError* serviceError = [weakSelf translateUpdateAPIError:error];
        if (serviceError) {
            [[weakSelf account] setGender:oldGender];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    }];
}

- (void)updateHeight:(NSNumber*)height completion:(nullable HEMAccountUpdateHandler)completion {
    NSNumber* oldHeight = [[self account] height];
    [[self account] setHeight:height];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        NSError* serviceError = [weakSelf translateUpdateAPIError:error];
        if (serviceError) {
            [[weakSelf account] setHeight:oldHeight];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    }];
}

- (void)updateWeight:(NSNumber*)weight completion:(nullable HEMAccountUpdateHandler)completion {
    NSNumber* oldWeight = [[self account] weight];
    [[self account] setWeight:weight];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        NSError* serviceError = [weakSelf translateUpdateAPIError:error];
        if (serviceError) {
            [[weakSelf account] setWeight:oldWeight];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    }];
}

- (void)updateFirstName:(NSString*)firstName
               lastName:(NSString*)lastName
             completion:(HEMAccountUpdateHandler)completion {
    NSString* oldFirstName = [[self account] firstName];
    NSString* oldLastName = [[self account] lastName];
    [[self account] setFirstName:firstName];
    [[self account] setLastName:lastName];
    
    __weak typeof(self) weakSelf = self;
    [self updateAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* serviceError = [weakSelf translateUpdateAPIError:error];
        if (serviceError) {
            [[strongSelf account] setFirstName:oldFirstName];
            [[strongSelf account] setLastName:oldLastName];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    }];
}

- (void)updateEmail:(NSString*)email completion:(nullable HEMAccountUpdateHandler)completion {
    NSString* trimmedEmail = [email trim];
    if ([trimmedEmail length] == 0) {
        if (completion) {
            completion ([self errorWithCode:HEMAccountServiceErrorInvalidArg]);
        }
        return;
    }
    
    NSString* oldEmail = [[self account] email];
    [[self account] setEmail:email];
    
    __weak typeof(self) weakSelf = self;
    
    void(^done)(NSError* error) =^(NSError* error) {
        NSError* serviceError = [weakSelf translateEmailUpdateAPIError:error];
        if (serviceError) {
            [[weakSelf account] setEmail:oldEmail];
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    };
    
    [SENAPIAccount changeEmailInAccount:[self account] completionBlock:^(id data, NSError *error) {
        if (error) {
            done (error);
        } else {
            // we need the latest account info for next update
            [weakSelf refresh:^(SENAccount * _Nonnull account, NSDictionary<NSNumber *,SENPreference *> * _Nonnull preferences) {
                done (nil);
            }];
        }
    }];
}

- (void)updatePassword:(NSString*)currentPassword
           newPassword:(NSString*)newPassword
            completion:(HEMAccountUpdateHandler)completion {
    
    NSString* email = [[self account] email];
    if (!email || !currentPassword || !newPassword) {
        if (completion) {
            completion ([self errorWithCode:HEMAccountServiceErrorEmailInvalid]);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    void(^done)(NSError* error) = ^(NSError* error) {
        NSError* serviceError = [weakSelf translatePasswordUpdateAPIError:error];
        if (serviceError) {
            [SENAnalytics trackError:serviceError];
        }
        if (completion) {
            completion (serviceError);
        }
    };
    
    
    [SENAPIAccount changePassword:currentPassword
                    toNewPassword:newPassword
                  completionBlock:^(id data, NSError *error) {
                      if (error) {
                          done (error);
                          return;
                      }
                      
                      [SENAuthorizationService reauthorizeUser:email
                                                      password:newPassword
                                                      callback:done];
                      
                  }];
}

#pragma mark - Account data

- (NSString*)localizedWeightInPreferredUnit {
    NSNumber* grams = [[self account] weight];
    if (!grams || [grams CGFloatValue] == 0.0f) {
        return nil;
    }
    
    if ([SENPreference useMetricUnitForWeight]) {
        CGFloat kg = roundCGFloat(HEMGramsToKilograms(grams));
        NSString* format = NSLocalizedString(@"measurement.kg.format", nil);
        return [NSString stringWithFormat:format, kg];
    } else {
        CGFloat pounds = roundCGFloat(HEMGramsToPounds(grams));
        NSString* format = NSLocalizedString(@"measurement.lb.format", nil);
        return [NSString stringWithFormat:format, pounds];
    }
}

- (NSString*)localizedHeightInPreferredUnit {
    NSNumber* cm = [[self account] height];
    if ([cm CGFloatValue] == 0.0f) {
        return nil;
    }
    
    if ([SENPreference useMetricUnitForHeight]) {
        CGFloat cmToDisplay = roundCGFloat([cm CGFloatValue]);
        NSString* format = NSLocalizedString(@"measurement.cm.format", nil);
        return [NSString stringWithFormat:format, (long)cmToDisplay];
    } else {
        CGFloat totalInches = HEMToInches(cm);
        CGFloat feet = floorCGFloat(totalInches / 12.0f);
        CGFloat inches = totalInches - (feet * 12.0f);
        NSString* feetFormat = NSLocalizedString(@"measurement.ft.format", nil);
        NSString* inchFormat = NSLocalizedString(@"measurement.in.format", nil);
        NSString* feetString = [NSString stringWithFormat:feetFormat, (long)feet];
        NSString* inchString = [NSString stringWithFormat:inchFormat, (long)inches];
        return [NSString stringWithFormat:@"%@ %@", feetString, inchString];
    }
}

#pragma mark - Preferences

- (BOOL)isEnabled:(SENPreferenceType)preferenceType {
    SENPreference* preference = [[self preferences] objectForKey:@(preferenceType)];
    return [preference isEnabled];
}

- (void)enablePreference:(BOOL)enable
                 forType:(SENPreferenceType)type
              completion:(HEMAccountUpdateHandler)completion {
    SENPreference* preference = [[self preferences] objectForKey:@(type)];
    if (!preference) {
        preference = [[SENPreference alloc] initWithType:type enable:enable];
    } else {
        [preference setEnabled:enable];
    }
    
    // optimistically update the preference locally
    [preference saveLocally];
    __weak typeof(self) weakSelf = self;
    [SENAPIPreferences updatePreferencesWithCompletion:^(NSDictionary* data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf setPreferences:data];
        }
        
        if (completion) {
            completion (error);
        }
    }];
}

#pragma mark - Authentication Notifications

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)didSignOut {
    [self setAccount:nil];
}

#pragma mark - Photos

- (void)uploadProfileJpegPhoto:(NSData*)data
                      progress:(HEMAccountProgressHandler)progress
                    completion:(HEMAccountPhotoHandler)completion {
    SENRemoteImage* oldPhoto = [[self account] photo];
    [[self account] setPhoto:nil];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIPhoto uploadProfilePhoto:data
                               type:SENAPIPhotoTypeJpeg
                           progress:progress
                         completion:^(id data, NSError *error) {
                             __strong typeof(weakSelf) strongSelf = weakSelf;
                             DDLogVerbose(@"photo data %@", data);
                             if (error) {
                                 [SENAnalytics trackError:error];
                                 [[strongSelf account] setPhoto:oldPhoto];
                             }
                             if (completion) {
                                 completion (data, error);
                             }
                         }];
}

- (void)removeProfilePhoto:(HEMAccountUpdateHandler)completion {
    SENRemoteImage* oldPhoto = [[self account] photo];
    [[self account] setPhoto:nil];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIPhoto deleteProfilePhoto:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
            [[strongSelf account] setPhoto:oldPhoto];
        }
        if (completion) {
            completion (error);
        }
    }];
}

@end
