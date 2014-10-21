
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <FXKeychain/FXKeychain.h>

#import "SENAuthorizationService.h"
#import "SENAPIClient.h"

NSString* const SENAuthorizationServiceKeychainService = @"is.hello.Sense";
NSString* const SENAuthorizationServiceKeychainGroup = @"MSG86J7GNF.is.hello.Sense";
NSString* const SENAuthorizationServiceDidAuthorizeNotification = @"SENAuthorizationServiceDidAuthorize";
NSString* const SENAuthorizationServiceDidDeauthorizeNotification = @"SENAuthorizationServiceDidDeauthorize";

@implementation SENAuthorizationService

static NSString* const SENAuthorizationServiceTokenPath = @"oauth2/token";
static NSString* const SENAuthorizationServiceClientID = @"iphone_pill";
static NSString* const SENAuthorizationServiceCredentialsKey = @"credentials";
static NSString* const SENAuthorizationServiceCredentialsEmailKey = @"email";
static NSString* const SENAuthorizationServiceAccountIdKey = @"account_id";
static NSString* const SENAuthorizationServiceAccessTokenKey = @"access_token";
static NSString* const SENAuthorizationServiceAuthorizationHeaderKey = @"Authorization";

+ (FXKeychain*)keychain {
    static FXKeychain* keychain = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keychain = [[FXKeychain alloc] initWithService:SENAuthorizationServiceKeychainService
                                           accessGroup:SENAuthorizationServiceKeychainGroup];
    });
    return keychain;
}

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
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        [self authorizeRequestsWithResponse:response];
        [self setEmailAddressOfAuthorizedUser:username];
        [self setAccountIdOfAuthorizedUser:response[SENAuthorizationServiceAccountIdKey]];
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
    [SENAPIClient DELETE:SENAuthorizationServiceTokenPath parameters:nil completion:NULL];
    [[self keychain] removeObjectForKey:SENAuthorizationServiceCredentialsKey];
    [self authorizeRequestsWithToken:nil];
    [self setEmailAddressOfAuthorizedUser:nil];
    [self setAccountIdOfAuthorizedUser:nil];
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

+ (NSString*)emailAddressOfAuthorizedUser
{
    return [self keychain][SENAuthorizationServiceCredentialsEmailKey];
}

+ (void)setEmailAddressOfAuthorizedUser:(NSString*)emailAddress
{
    [self keychain][SENAuthorizationServiceCredentialsEmailKey] = emailAddress;
}

+ (NSString*)accountIdOfAuthorizedUser
{
    return [self keychain][SENAuthorizationServiceAccountIdKey];
}

+ (void)setAccountIdOfAuthorizedUser:(NSString*)accountId
{
    [self keychain][SENAuthorizationServiceAccountIdKey] = accountId;
}

+ (NSString*)accessToken
{
    return [self keychain][SENAuthorizationServiceCredentialsKey][SENAuthorizationServiceAccessTokenKey];
}

#pragma mark Private

+ (id)authorizationHeaderValue
{
    return [SENAPIClient defaultHTTPHeaderValues][SENAuthorizationServiceAuthorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain
{
    id token = [self accessToken];
    if (token)
        [self authorizeRequestsWithToken:token];
}

+ (void)authorizeRequestsWithResponse:(id)responseObject
{
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[self keychain] setObject:responseObject forKey:SENAuthorizationServiceCredentialsKey];
    [self authorizeRequestsWithToken:responseData[SENAuthorizationServiceAccessTokenKey]];
}

+ (void)authorizeRequestsWithToken:(NSString*)token
{
    NSString* headerValue = token ? [NSString stringWithFormat:@"Bearer %@", token] : nil;
    [SENAPIClient setValue:headerValue forHTTPHeaderField:SENAuthorizationServiceAuthorizationHeaderKey];
    if (token) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidAuthorizeNotification object:self userInfo:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SENAuthorizationServiceDidDeauthorizeNotification object:self userInfo:nil];
    }
}

@end
