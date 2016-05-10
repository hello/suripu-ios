
#import <AFNetworking/AFHTTPSessionManager.h>
#import <FXKeychain/FXKeychain.h>

#import "SENAuthorizationService.h"
#import "SENAPIAccount.h"
#import "SENAPIClient.h"

NSString* const SENAuthorizationServiceKeychainService = @"is.hello.Sense";
NSString* const SENAuthorizationServiceKeychainGroup = @"MSG86J7GNF.is.hello.Sense";
NSString* const SENAuthorizationServiceDidAuthorizeNotification = @"SENAuthorizationServiceDidAuthorize";
NSString* const SENAuthorizationServiceDidDeauthorizeNotification = @"SENAuthorizationServiceDidDeauthorize";
NSString* const SENAuthorizationServiceDidReauthorizeNotification = @"SENAuthorizationServiceDidReauthorize";

@implementation SENAuthorizationService

static NSString* SENAuthorizationServiceClientID = nil;
static NSString* const SENAuthorizationServiceTokenPath = @"v1/oauth2/token";
static NSString* const SENAuthorizationServiceCredentialsKey = @"credentials";
static NSString* const SENAuthorizationServiceAccountIdKey = @"account_id";
static NSString* const SENAuthorizationServiceAccessTokenKey = @"access_token";
static NSInteger const SENAuthorizationServiceDeauthorizationCode = 401;
static NSString* const SENAuthorizationServiceAuthorizationHeaderKey = @"Authorization";
static NSString* const SENAuthorizationServiceContentType = @"application/x-www-form-urlencoded";

+ (FXKeychain*)keychain {
    static FXKeychain* keychain = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keychain = [[FXKeychain alloc] initWithService:SENAuthorizationServiceKeychainService
                                           accessGroup:SENAuthorizationServiceKeychainGroup];
    });
    return keychain;
}

+ (void)setClientAppID:(NSString *)clientID
{
    SENAuthorizationServiceClientID = clientID;
}

+ (void)authorizeWithUsername:(NSString *)username
                     password:(NSString *)password
                 notification:(NSString*)notification
                     callback:(void(^)(NSError* error))block
{
    [self authorize:username password:password onCompletion:^(NSDictionary *response, NSError *error) {
        if (error == nil) {
            [self authorizeRequestsWithResponse:response notify:notification];
            [self setAccountIdOfAuthorizedUser:response[SENAuthorizationServiceAccountIdKey]];
        }
        if (block) block(error);
    }];
}

+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError*))block
{
    [self authorizeWithUsername:username
                       password:password
                   notification:SENAuthorizationServiceDidAuthorizeNotification
                       callback:block];
}

+ (void)reauthorizeUser:(NSString*)username password:(NSString*)password callback:(void(^)(NSError* error))block
{
    [self authorizeWithUsername:username
                       password:password
                   notification:SENAuthorizationServiceDidReauthorizeNotification
                       callback:block];
}

+ (AFHTTPSessionManager*)sessionManager {
    static AFHTTPSessionManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer new];
        [serializer setValue:SENAuthorizationServiceContentType forHTTPHeaderField:@"Content-Type"];
        
        manager = [AFHTTPSessionManager manager];
        [manager setRequestSerializer:serializer];
    });
    return manager;
}

+ (void)deauthorize
{
    if ([self isAuthorized]) {
        [SENAPIClient DELETE:SENAuthorizationServiceTokenPath parameters:nil completion:NULL];
        [[self keychain] removeObjectForKey:SENAuthorizationServiceCredentialsKey];
        [self authorizeRequestsWithToken:nil];
        [self setAccountIdOfAuthorizedUser:nil];
        [self notify:SENAuthorizationServiceDidDeauthorizeNotification];
    }
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

+ (BOOL)isAuthorizedRequest:(NSURLRequest*)request
{
    return request.allHTTPHeaderFields[SENAuthorizationServiceAuthorizationHeaderKey] != nil;
}

+ (BOOL)isAuthorizationError:(NSError*)error
{
    NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    return response.statusCode == SENAuthorizationServiceDeauthorizationCode;
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

+ (void)authorize:(NSString*)username password:(NSString*)password onCompletion:(void(^)(NSDictionary* response, NSError* error))block {
    if (SENAuthorizationServiceClientID.length == 0) {
        if (block)
            block(nil, [NSError errorWithDomain:@"is.hello" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"No client ID set"}]);
        return;
    }
    NSDictionary* params = @{ @"grant_type" : @"password",
                              @"client_id" : SENAuthorizationServiceClientID,
                              @"username" : username ?: @"",
                              @"password" : password ?: @"" };
    
    NSURL* url = [[SENAPIClient baseURL] URLByAppendingPathComponent:SENAuthorizationServiceTokenPath];
    
    AFHTTPSessionManager* manager = [self sessionManager];
    [manager POST:[url absoluteString] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* response = nil;
        if ([responseObject isKindOfClass:[NSData class]]) {
            response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        } else if ([responseObject isKindOfClass:[NSDictionary class]]) {
            response = responseObject;
        } // else, ignore the response
        if (block) {
            block(response, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (id)authorizationHeaderValue
{
    return [SENAPIClient defaultHTTPHeaderValues][SENAuthorizationServiceAuthorizationHeaderKey];
}

+ (void)authorizeRequestsFromKeychain
{
    id token = [self accessToken];
    if (token) {
        [self authorizeRequestsWithToken:token];
        [self notify:SENAuthorizationServiceDidAuthorizeNotification];
    }
}

+ (void)authorizeRequestsWithResponse:(id)responseObject notify:(NSString*)notificationName
{
    NSDictionary* responseData = (NSDictionary*)responseObject;
    [[self keychain] setObject:responseObject forKey:SENAuthorizationServiceCredentialsKey];
    [self authorizeRequestsWithToken:responseData[SENAuthorizationServiceAccessTokenKey]];
    [self notify:notificationName];
}

+ (void)authorizeRequestsWithToken:(NSString*)token
{
    NSString* headerValue = token ? [NSString stringWithFormat:@"Bearer %@", token] : nil;
    [SENAPIClient setValue:headerValue forHTTPHeaderField:SENAuthorizationServiceAuthorizationHeaderKey];
}

+ (void)notify:(NSString*)name {
    if (name) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:nil];
    }
}

@end
