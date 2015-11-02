
//
//  SENServiceAccount.m
//  Pods
//
//  Created by Jimmy Lu on 12/5/14.
//
//
#import <AFNetworking/AFNetworking.h>

#import "SENServiceAccount.h"
#import "SENAPIAccount.h"
#import "SENAPIPreferences.h"
#import "SENAuthorizationService.h"
#import "SENAccount.h"
#import "SENService+Protected.h"
#import "SENPreference.h"

NSString* const SENServiceAccountErrorDomain = @"is.hello.service.account";

@interface SENServiceAccount()

@property (nonatomic, strong) SENAccount* account;
@property (nonatomic, strong) NSDictionary* preferences;

@end

@implementation SENServiceAccount

+ (id)sharedService {
    static SENServiceAccount* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (id)init {
    self = [super init];
    if (self) {
        [self listenForAuthChanges];
    }
    return self;
}

- (NSError*)errorWithCode:(SENServiceAccountError)code {
    return [NSError errorWithDomain:SENServiceAccountErrorDomain
                               code:code
                           userInfo:nil];
}

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [self setAccount:nil];
    [self setPreferences:nil];
}

- (NSString*)trim:(NSString*)value {
    NSCharacterSet* spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [value stringByTrimmingCharactersInSet:spaces];
}

#pragma mark - Authentication Changes

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
    [center addObserver:self selector:@selector(didSignIn)
                   name:SENAuthorizationServiceDidAuthorizeNotification
                 object:nil];
}

- (void)didSignOut {
    [self setAccount:nil];
}

- (void)didSignIn {
    [self refreshAccount:nil];
}

#pragma mark - Account Management

- (NSError*)commonServiceErrorFromAPIError:(NSError*)error unrecognizedStatusCode:(NSInteger*)statusCode {
    SENAPIAccountError accountError = [SENAPIAccount errorForAPIResponseError:error];
    switch (accountError) {
        case SENAPIAccountErrorInvalidArgument:
            return [self errorWithCode:SENServiceAccountErrorInvalidArg];
        case SENAPIAccountErrorNameTooShort:
            return [self errorWithCode:SENServiceAccountErrorNameTooShort];
        case SENAPIAccountErrorEmailInvalid:
            return [self errorWithCode:SENServiceAccountErrorEmailInvalid];
        case SENAPIAccountErrorNameTooLong:
            return [self errorWithCode:SENServiceAccountErrorNameTooLong];
        case SENAPIAccountErrorPasswordInsecure:
            return [self errorWithCode:SENServiceAccountErrorPasswordInsecure];
        case SENAPIAccountErrorPasswordTooShort:
            return [self errorWithCode:SENServiceAccountErrorPasswordTooShort];
        case SENAPIAccountErrorUnknown:
        default: {
            NSHTTPURLResponse* response = [error userInfo][AFNetworkingOperationFailingURLResponseErrorKey];
            switch ([response statusCode]) {
                case 412:
                    return [self errorWithCode:SENServiceAccountErrorAccountNotUpToDate];
                case 500:
                    return [self errorWithCode:SENServiceAccountErrorServerFailure];
                default:
                    if (statusCode != NULL) {
                        *statusCode = [response statusCode];
                    }
                    return nil;
            }
        }
    }
}

- (void)refreshAccount:(SENAccountResponseBlock)completion {
    __block BOOL accountUpdated = NO;
    __block BOOL preferencesUpdated = NO;
    __block SENAccountResponseBlock callback = completion;
    __block NSError* accountError = nil;
    __block NSError* preferencesError = nil;
    __weak typeof(self) weakSelf = self;
    
    void(^finishBlock)(void) = ^(void) {
        if (callback && accountUpdated && preferencesUpdated) {
            NSError* serviceError = nil;
            NSError* apiError = nil;
            if (accountError || preferencesError) {
                // account error takes precedence
                apiError = accountError ?: preferencesError;
                serviceError = [weakSelf commonServiceErrorFromAPIError:apiError
                                                 unrecognizedStatusCode:nil];
            }
            callback(serviceError ?: apiError);
        }
    };
    
    [SENAPIAccount getAccount:^(SENAccount* response, NSError *error) {
        if (error == nil) {
            [weakSelf setAccount:response];
        }
        accountError = error;
        accountUpdated = YES;
        finishBlock();
    }];
    
    [SENAPIPreferences getPreferences:^(NSDictionary* data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            [strongSelf setPreferences:data];
            [[data allValues] makeObjectsPerformSelector:@selector(saveLocally)];
        }
        preferencesUpdated = YES;
        preferencesError = error;
        finishBlock();
    }];
}

#pragma mark Password

- (NSError*)translatePasswordUpdateAPIError:(NSError*)error {
    NSInteger unrecognizedCode = 0;
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:&unrecognizedCode];
    
    if (!serviceError) {
        switch (unrecognizedCode) {
            case 409:
                serviceError = [self errorWithCode:SENServiceAccountErrorPasswordNotRecognized];
                break;
            default:
                serviceError = error; // pass error through since it can't be interpreted here
                break;
        }
    }

    return serviceError;
}

- (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
           forUsername:(NSString*)username
            completion:(SENAccountResponseBlock)completion {
    
    if ([currentPassword length] == 0 || [password length] == 0 || [username length] == 0) {
        return [self callIfSafe:completion
                      withError:[self errorWithCode:SENServiceAccountErrorInvalidArg]];
    }
    
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount changePassword:currentPassword
                    toNewPassword:password
                  completionBlock:^(id data, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      if (error) {
                          return [strongSelf callIfSafe:completion
                                              withError:[strongSelf translatePasswordUpdateAPIError:error]];
                      }
                      
                      [SENAuthorizationService reauthorizeUser:username
                                                      password:password
                                                      callback:completion];
                      
                  }];
}

#pragma mark Email

- (NSError*)translateEmailUpdateAPIError:(NSError*)error {
    NSInteger unrecognizedCode = 0;
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:&unrecognizedCode];
    
    if (!serviceError) {
        switch (unrecognizedCode) {
            case 409:
                serviceError = [self errorWithCode:SENServiceAccountErrorEmailAlreadyExists];
                break;
            default:
                serviceError = error; // pass error through since it can't be interpreted here
                break;
        }
    }
    
    return serviceError;
}

- (void)changeEmail:(NSString*)email completion:(SENAccountResponseBlock)completion {
    
    NSString* trimmedEmail = [self trim:email];
    if ([trimmedEmail length] == 0) {
        return [self callIfSafe:completion
                            withError:[self errorWithCode:SENServiceAccountErrorInvalidArg]];
    }
    
    // force a refreh, even if an account already exists
    __weak typeof(self) weakSelf = self;
    [self refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            [strongSelf callIfSafe:completion withError:error];
        } else {
            [[strongSelf account] setEmail:trimmedEmail];
            [SENAPIAccount changeEmailInAccount:[strongSelf account]
                                completionBlock:^(id data, NSError *error) {
                                    NSError* serviceError = nil;
                                    if (error) {
                                        serviceError = [strongSelf translateEmailUpdateAPIError:error];
                                    }
                                    [strongSelf callIfSafe:completion withError:serviceError];
                                }];
        }
    }];
}

#pragma mark Name

- (NSError*)transateNameUpdateAPIError:(NSError*)error {
    NSError* serviceError = [self commonServiceErrorFromAPIError:error
                                          unrecognizedStatusCode:nil];
    return serviceError ?: error;
}

- (void)changeName:(NSString *)name completion:(SENAccountResponseBlock)completion {
    if (name.length == 0) {
        return [self callIfSafe:completion
                      withError:[self errorWithCode:SENServiceAccountErrorInvalidArg]];
    }
    __weak typeof(self) weakSelf = self;
    [self refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            return [strongSelf callIfSafe:completion withError:error];
        }
        [[strongSelf account] setName:name];
        [SENAPIAccount updateAccount:[strongSelf account] completionBlock:^(id data, NSError *error) {
            NSError* serviceError = nil;
            if (error) {
                serviceError = [strongSelf transateNameUpdateAPIError:error];
            }
            [strongSelf callIfSafe:completion withError:serviceError];
        }];
    }];
}

- (void)updateAccount:(SENAccountResponseBlock)completion {
    
    __weak typeof(self) weakSelf = self;
    __block SENAccountResponseBlock callback = completion ?: ^(NSError* error){};
    
    void(^update)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            callback(error);
            return;
        }
        
        [SENAPIAccount updateAccount:[strongSelf account] completionBlock:^(SENAccount* account, NSError *error) {
            NSError* serviceError = nil;
            if (!error && account) {
                [strongSelf setAccount:account];
            } else if (error) {
                serviceError = [strongSelf commonServiceErrorFromAPIError:error
                                                   unrecognizedStatusCode:nil];
            }
            callback(serviceError ?: error);
        }];
    };
    
    if ([self account] == nil) {
        [self refreshAccount:update];
    } else {
        update(nil);
    }

}

- (void)updatePreference:(SENPreference*)preference completion:(SENAccountResponseBlock)completion {
    if (preference == nil) {
        return [self callIfSafe:completion
                      withError:[self errorWithCode:SENServiceAccountErrorInvalidArg]];
    }

    // optimistically update the preference locally
    [preference saveLocally];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIPreferences updatePreferencesWithCompletion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError* serviceError = nil;
        if (!error) {
            NSMutableDictionary* updatedPref = [[strongSelf preferences] mutableCopy];
            if (updatedPref == nil) updatedPref = [NSMutableDictionary dictionary];
            [updatedPref setObject:preference forKey:@([preference type])];
            [strongSelf setPreferences:updatedPref];
        } else {
            serviceError = [strongSelf commonServiceErrorFromAPIError:error
                                               unrecognizedStatusCode:nil];
        }
        [strongSelf callIfSafe:completion withError:serviceError ?: error];
    }];
}

// observer already removed in SENService

@end
