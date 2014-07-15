
#import <AFNetworking/AFHTTPSessionManager.h>
#import <FXKeychain/FXKeychain.h>

#import "SENAuthorizationService.h"
#import "SENAPIClient.h"

NSString* const SENAuthorizationServiceDidAuthorizeNotification = @"SENAuthorizationServiceDidAuthorize";
NSString* const SENAuthorizationServiceDidDeauthorizeNotification = @"SENAuthorizationServiceDidDeauthorize";

static NSString* const SEN_tokenPath = @"oauth2/token";
static NSString* const SEN_applicationClientID = @"iphone_pill";
static NSString* const SEN_credentialsKey = @"credentials";
static NSString* const SEN_accessTokenKey = @"access_token";
static NSString* const SEN_authorizationHeaderKey = @"Authorization";

@implementation SENAuthorizationService

+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError*))block
{
    NSDictionary* params = @{ @"grant_type" : @"password",
                              @"client_id" : SEN_applicationClientID,
                              @"username" : username ?: @"",
                              @"password" : password ?: @"" };

    [[SENAPIClient HTTPSessionManager] POST:SEN_tokenPath parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        [self authorizeRequestsWithResponse:responseObject];
        if (block)
            block(task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (block)
            block(error);
    }];
}

+ (void)deauthorize
{
    [[FXKeychain defaultKeychain] removeObjectForKey:SEN_credentialsKey];
    [self authorizeRequestsWithToken:nil];
}

+ (BOOL)isAuthorized
{
    id token = [self authorizationHeaderValue];
    if (!token) {
        [self authorizeRequestsFromKeychain];
        token = [self authorizationHeaderValue];
    }

    return token != nil;
}

#pragma mark Private

+ (id)authorizationHeaderValue
{
    return [[SENAPIClient HTTPSessionManager].requestSerializer HTTPRequestHeaders][SEN_authorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain
{
    id token = [FXKeychain defaultKeychain][SEN_credentialsKey][SEN_accessTokenKey];
    if (token)
        [self authorizeRequestsWithToken:token];
}

+ (void)authorizeRequestsWithResponse:(id)responseObject
{
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[FXKeychain defaultKeychain] setObject:responseObject forKey:SEN_credentialsKey];
    [self authorizeRequestsWithToken:responseData[SEN_accessTokenKey]];
}

+ (void)authorizeRequestsWithToken:(NSString*)token
{
    [[SENAPIClient HTTPSessionManager].requestSerializer setValue:token forHTTPHeaderField:SEN_authorizationHeaderKey];
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidAuthorizeNotification object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidDeauthorizeNotification object:self userInfo:nil];
    }
}

@end
