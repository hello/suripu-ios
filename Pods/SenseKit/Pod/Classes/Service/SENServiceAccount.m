//
//  SENServiceAccount.m
//  Pods
//
//  Created by Jimmy Lu on 12/5/14.
//
//
#import "SENServiceAccount.h"
#import "SENAPIAccount.h"
#import "SENAPIPreferences.h"
#import "SENAuthorizationService.h"
#import "SENAccount.h"
#import "SENService+Protected.h"
#import "SENPreference.h"

static NSString* const SENServiceAccountErrorDomain = @"is.hello.service.account";

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

- (void)refreshAccount:(SENAccountResponseBlock)completion {
    __block BOOL accountUpdated = NO;
    __block BOOL preferencesUpdated = NO;
    __block SENAccountResponseBlock callback = completion;
    
    SENAccountResponseBlock finishBlock = ^(NSError* error) {
        if (callback && accountUpdated && preferencesUpdated) {
            callback(error);
        }
    };
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccount:^(SENAccount* response, NSError *error) {
        if (error == nil) {
            [weakSelf setAccount:response];
        }
        accountUpdated = YES;
        finishBlock(error);
    }];
    
    [SENAPIPreferences getPreferences:^(NSDictionary* data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            [strongSelf setPreferences:data];
            [[data allValues] makeObjectsPerformSelector:@selector(saveLocally)];
        }
        preferencesUpdated = YES;
        finishBlock(error);
    }];
}

- (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
           forUsername:(NSString*)username
            completion:(SENAccountResponseBlock)completion {
    
    if ([currentPassword length] == 0 || [password length] == 0) {
        if (completion) completion ([self errorWithCode:SENServiceAccountErrorInvalidArg]);
        return;
    }
    
    [SENAPIAccount changePassword:currentPassword
                    toNewPassword:password
                  completionBlock:^(id data, NSError *error) {
                      if (error) {
                          if (completion) {
                              completion (error);
                          }
                          return;
                      }
                      
                      [SENAuthorizationService reauthorizeUser:username password:password callback:completion];
                      
                  }];
}

- (void)changeEmail:(NSString*)email completion:(SENAccountResponseBlock)completion {
    
    if ([email length] == 0) {
        if (completion) completion ([self errorWithCode:SENServiceAccountErrorInvalidArg]);
        return;
    }
    
    // force a refreh, even if an account already exists
    __weak typeof(self) weakSelf = self;
    [self refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            if (completion) completion (error);
        } else if (strongSelf) {
            [[strongSelf account] setEmail:email];
            [SENAPIAccount changeEmailInAccount:[strongSelf account]
                                completionBlock:^(id data, NSError *error) {
                                    if (completion) completion (error);
                                }];
        }
    }];
}

- (void)changeName:(NSString *)name completion:(SENAccountResponseBlock)completion {
    if (name.length == 0) {
        if (completion)
            completion([self errorWithCode:SENServiceAccountErrorInvalidArg]);
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self refreshAccount:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            if (completion)
                completion(error);
            return;
        }
        [[strongSelf account] setName:name];
        [SENAPIAccount updateAccount:[strongSelf account] completionBlock:^(id data, NSError *error) {
            if (completion)
                completion(error);
        }];
    }];
}

- (void)updateAccount:(SENAccountResponseBlock)completion {
    
    __weak typeof(self) weakSelf = self;
    __block SENAccountResponseBlock callback = completion ?: ^(NSError* error){};
    
    void(^update)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error != nil) {
            callback(error);
        }
        [SENAPIAccount updateAccount:[strongSelf account] completionBlock:^(SENAccount* account, NSError *updateError) {
            if (error == nil && account != nil) {
                [strongSelf setAccount:account];
            }
            callback(error);
        }];
    };
    
    if ([self account] == nil) {
        [self refreshAccount:^(NSError *error) {
            update(error);
        }];
    } else {
        update(nil);
    }

}

- (void)updatePreference:(SENPreference*)preference completion:(SENAccountResponseBlock)completion {
    if (preference == nil) {
        if (completion) completion ([NSError errorWithDomain:SENServiceAccountErrorDomain
                                                        code:SENServiceAccountErrorInvalidArg
                                                    userInfo:nil]);
        return;
    }

    // optimistically update the preference locally
    [preference saveLocally];
    
    __weak typeof(self) weakSelf = self;
    [SENAPIPreferences updatePreferencesWithCompletion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error == nil) {
            NSMutableDictionary* updatedPref = [[strongSelf preferences] mutableCopy];
            if (updatedPref == nil) updatedPref = [NSMutableDictionary dictionary];
            [updatedPref setObject:preference forKey:@([preference type])];
            [strongSelf setPreferences:updatedPref];
        }
        if (completion) completion (error);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
