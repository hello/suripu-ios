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

- (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
            completion:(SENAccountResponseBlock)completion {
    NSString* email = [SENAuthorizationService emailAddressOfAuthorizedUser];
    
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
}

@end
