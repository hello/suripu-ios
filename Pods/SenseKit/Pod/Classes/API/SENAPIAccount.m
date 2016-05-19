
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"
#import "Model.h"

NSString* const kSENAccountNotificationAccountCreated = @"SENAccountCreated";

NSString* const SENAPIAccountEndpoint = @"v1/account";
NSString* const SENAPIAccountErrorDomain = @"is.hello.account";

NSString* const SENAPIAccountPropertyName = @"name";
NSString* const SENAPIAccountPropertyEmailAddress = @"email";
NSString* const SENAPIAccountPropertyPassword = @"password";
NSString* const SENAPIAccountPropertyTimezoneOffset = @"tz";
NSString* const SENAPIAccountPropertyCurrentPassword = @"current_password";
NSString* const SENAPIAccountPropertyNewPassword = @"new_password";
NSString* const SENAPIAccountErrorResponseMessageKey= @"message";
NSString* const SENAPIAccountErrorMessagePasswordTooShort = @"PASSWORD_TOO_SHORT";
NSString* const SENAPIAccountErrorMessagePasswordInsecure = @"PASSWORD_INSECURE";
NSString* const SENAPIAccountErrorMessageNameTooLong = @"NAME_TOO_LONG";
NSString* const SENAPIAccountErrorMessageNameTooShort = @"NAME_TOO_SHORT";
NSString* const SENAPIAccountErrorMessageEmailInvalid = @"EMAIL_INVALID";

@implementation SENAPIAccount

+ (NSNumber*)currentTimezoneInMillis {
    return @([[NSTimeZone localTimeZone] secondsFromGMT] * 1000);
}

+ (void)createAccount:(SENAccount*)account
         withPassword:(NSString*)password
           completion:(SENAPIDataBlock)completion {
    NSMutableDictionary* params = [[account dictionaryValue] mutableCopy];
    params[SENAPIAccountPropertyPassword] = password;
    params[SENAPIAccountPropertyTimezoneOffset] = [self currentTimezoneInMillis]; // deprecated.  will remove in future versions
    
    NSString* path = [NSString stringWithFormat:@"%@?sig=%@", SENAPIAccountEndpoint, @"xxx"];
    [SENAPIClient POST:path parameters:params completion:^(id responseObject, NSError *error) {
        SENAccount* createdAccount = nil;
        if (error == nil && [responseObject isKindOfClass:[NSDictionary class]]) {
            createdAccount = [[SENAccount alloc] initWithDictionary:responseObject];
            if (createdAccount != nil) {
                NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kSENAccountNotificationAccountCreated
                                      object:nil];
            }
        }
        completion(createdAccount, error);
    }];
}

+ (void)updateAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    NSMutableDictionary* params = [[account dictionaryValue] mutableCopy];
    params[SENAPIAccountPropertyTimezoneOffset] = [self currentTimezoneInMillis]; // deprecated.  will remove in future versions
    
    [SENAPIClient PUT:SENAPIAccountEndpoint parameters:params completion:^(id data, NSError *error) {
        SENAccount* account = nil;
        if (error == nil && [data isKindOfClass:[NSDictionary class]]) {
            account = [[SENAccount alloc] initWithDictionary:data];
        }
        if (completion) completion (account, error);
    }];
}

+ (void)getAccount:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIAccountEndpoint
           parameters:nil
           completion:^(id data, NSError *error) {
               SENAccount* account = nil;
               if ([data isKindOfClass:[NSDictionary class]]) {
                   account = [[SENAccount alloc] initWithDictionary:data];
               }
               completion(account, error);
           }];
}

+ (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
       completionBlock:(SENAPIDataBlock)completion {
    if ([currentPassword length] == 0 || [password length] == 0) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIAccountErrorDomain
                                                 code:SENAPIAccountErrorInvalidArgument
                                             userInfo:nil]);
        }
        return;
    }
    NSDictionary* body = @{SENAPIAccountPropertyCurrentPassword : currentPassword,
                           SENAPIAccountPropertyNewPassword : password};
    NSString* path = [SENAPIAccountEndpoint stringByAppendingPathComponent:@"password"];
    [SENAPIClient POST:path parameters:body completion:completion];
}

+ (void)changeEmailInAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    if (account == nil || [[account email] length] == 0) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIAccountErrorDomain
                                                 code:SENAPIAccountErrorInvalidArgument
                                             userInfo:nil]);
        }
        return;
    }
    
    NSDictionary* body = [account dictionaryValue];
    NSString* path = [SENAPIAccountEndpoint stringByAppendingPathComponent:@"email"];
    [SENAPIClient POST:path parameters:body completion:completion];
}

+ (SENAPIAccountError)errorForAPIResponseError:(NSError*)error {
    NSData* errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    SENAPIAccountError errorType = SENAPIAccountErrorUnknown;

    if (errorData != nil) {
        id errorResponse = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableContainers error:nil];
        if ([errorResponse isKindOfClass:[NSDictionary class]]) {
            NSString* responseMessage = errorResponse[SENAPIAccountErrorResponseMessageKey];
            if ([responseMessage isEqualToString:SENAPIAccountErrorMessagePasswordTooShort]) {
                errorType = SENAPIAccountErrorPasswordTooShort;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessagePasswordInsecure]) {
                errorType = SENAPIAccountErrorPasswordInsecure;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageNameTooLong]) {
                errorType = SENAPIAccountErrorNameTooLong;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageNameTooShort]) {
                errorType = SENAPIAccountErrorNameTooShort;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageEmailInvalid]) {
                errorType = SENAPIAccountErrorEmailInvalid;
            }
        }
    }
    
    return errorType;
}

@end
