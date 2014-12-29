//
//  SENServiceAccount.m
//  Pods
//
//  Created by Jimmy Lu on 12/5/14.
//
//
#import "SENServiceAccount.h"
#import "SENAPIAccount.h"
#import "SENAuthorizationService.h"
#import "SENAccount.h"

static NSString* const SENServiceAccountErrorDomain = @"is.hello.service.account";

@interface SENServiceAccount()

@property (nonatomic, strong) SENAccount* account;

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

#pragma mark - Authentication Changes

- (void)listenForAuthChanges {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didSignOut)
                   name:SENAuthorizationServiceDidDeauthorizeNotification
                 object:nil];
}

- (void)didSignOut {
    [self setAccount:nil];
}

#pragma mark - Account Management

- (void)refreshAccount:(SENAccountResponseBlock)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIAccount getAccount:^(SENAccount* response, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                if (completion) completion (error);
                return;
            }
            [strongSelf setAccount:response];
            if (completion) completion (nil);
        }
    }];
}

- (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
            completion:(SENAccountResponseBlock)completion {
    
    if ([currentPassword length] == 0 || [password length] == 0) {
        if (completion) completion ([self errorWithCode:SENServiceAccountErrorInvalidArg]);
        return;
    }
    
    void(^changePassword)(NSString* email) = ^(NSString* email) {
        [SENAPIAccount changePassword:currentPassword
                        toNewPassword:password
                      completionBlock:^(id data, NSError *error) {
                          if (error) {
                              if (completion) {
                                  completion (error);
                              }
                              return;
                          }
                          
                          [SENAuthorizationService authorizeWithUsername:email
                                                                password:password
                                                                callback:completion];
                          
                      }];
    };
    
    NSString* email = [[self account] email];
    
    if (email == nil) {
        __weak typeof(self) weakSelf = self;
        [self refreshAccount:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error != nil) {
                if (completion) completion (error);
            } else if (strongSelf) {
                changePassword ([[strongSelf account] email]);
            }
            
        }];
    } else {
        changePassword (email);
    }
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
