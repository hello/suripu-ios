
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"
#import "Model.h"

NSString* const kSENAccountNotificationAccountCreated = @"SENAccountCreated";

NSString* const SENAPIAccountEndpoint = @"v1/account";
NSString* const SENAPIAccountErrorDomain = @"is.hello.account";

NSString* const SENAPIAccountPropertyName = @"name";
NSString* const SENAPIAccountPropertyEmailAddress = @"email";
NSString* const SENAPIAccountPropertyPassword = @"password";
NSString* const SENAPIAccountPropertyTimezone = @"tz";
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

+ (void)createAccountWithName:(NSString*)name
                 emailAddress:(NSString*)emailAddress
                     password:(NSString*)password
                   completion:(SENAPIDataBlock)completionBlock {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:5];

    if (password)
        params[SENAPIAccountPropertyPassword] = password;
    if (emailAddress)
        params[SENAPIAccountPropertyEmailAddress] = emailAddress;
    if (name)
        params[SENAPIAccountPropertyName] = name;
    params[SENAPIAccountPropertyTimezone] = [self currentTimezoneInMillis];

    NSString* URLPath = [NSString stringWithFormat:@"%@?sig=%@", SENAPIAccountEndpoint, @"xxx"];

    [SENAPIClient POST:URLPath parameters:params completion:^(id responseObject, NSError *error) {
        SENAccount* account = nil;
        if (error == nil && [responseObject isKindOfClass:[NSDictionary class]]) {
            account = [[SENAccount alloc] initWithDictionary:responseObject];
            if (account != nil) {
                NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kSENAccountNotificationAccountCreated
                                      object:nil];
            }
        }
        completionBlock(account, error);
    }];
}

+ (void)updateAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    NSMutableDictionary* accountDict = [[account dictionaryValue] mutableCopy];
    accountDict[SENAPIAccountPropertyTimezone] = [self currentTimezoneInMillis];
    
    [SENAPIClient PUT:SENAPIAccountEndpoint parameters:accountDict completion:^(id data, NSError *error) {
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
