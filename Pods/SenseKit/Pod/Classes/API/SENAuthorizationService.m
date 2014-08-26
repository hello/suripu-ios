
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <FXKeychain/FXKeychain.h>

#import "SENAuthorizationService.h"
#import "SENAPIClient.h"

NSString* const SENAuthorizationServiceDidAuthorizeNotification = @"SENAuthorizationServiceDidAuthorize";
NSString* const SENAuthorizationServiceDidDeauthorizeNotification = @"SENAuthorizationServiceDidDeauthorize";

static NSString* const SENAuthorizationServiceTokenPath = @"oauth2/token";
static NSString* const SENAuthorizationServiceClientID = @"iphone_pill";
static NSString* const SENAuthorizationServiceCredentialsKey = @"credentials";
static NSString* const SENAuthorizationServiceAccessTokenKey = @"access_token";
static NSString* const SENAuthorizationServiceAuthorizationHeaderKey = @"Authorization";

@implementation SENAuthorizationService

+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError*))block
{
    NSDictionary* params = @{ @"grant_type" : @"password",
                              @"client_id" : SENAuthorizationServiceClientID,
                              @"username" : username ?: @"",
                              @"password" : password ?: @"" };

    NSURL* url = [[SENAPIClient baseURL] URLByAppendingPathComponent:SENAuthorizationServiceTokenPath];
    NSMutableURLRequest* request = [[self requestSerializer] requestWithMethod:@"POST" URLString:[url absoluteString] parameters:params error:nil];

    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation, id responseObject) {
        [self authorizeRequestsWithResponse:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]];
        if (block)
            block(operation.error);
    } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
        if (block)
            block(error);
    }];
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:operation];
}

+ (AFHTTPRequestSerializer*)requestSerializer
{
    static AFHTTPRequestSerializer* serializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serializer = [[AFHTTPRequestSerializer alloc] init];
        [serializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    });
    return serializer;
}

+ (void)deauthorize
{
    [[FXKeychain defaultKeychain] removeObjectForKey:SENAuthorizationServiceCredentialsKey];
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
    return [[SENAPIClient HTTPSessionManager].requestSerializer HTTPRequestHeaders][SENAuthorizationServiceAuthorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain
{
    id token = [FXKeychain defaultKeychain][SENAuthorizationServiceCredentialsKey][SENAuthorizationServiceAccessTokenKey];
    if (token)
        [self authorizeRequestsWithToken:token];
}

+ (void)authorizeRequestsWithResponse:(id)responseObject
{
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[FXKeychain defaultKeychain] setObject:responseObject forKey:SENAuthorizationServiceCredentialsKey];
    [self authorizeRequestsWithToken:responseData[SENAuthorizationServiceAccessTokenKey]];
}

+ (void)authorizeRequestsWithToken:(NSString*)token
{
    NSString* headerValue = token ? [NSString stringWithFormat:@"Bearer %@", token] : nil;
    [[SENAPIClient HTTPSessionManager].requestSerializer setValue:headerValue forHTTPHeaderField:SENAuthorizationServiceAuthorizationHeaderKey];
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidAuthorizeNotification object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidDeauthorizeNotification object:self userInfo:nil];
    }
}

@end
