
#import <AFNetworking/AFHTTPSessionManager.h>
#import <NSJSONSerialization-NSNullRemoval/NSJSONSerialization+RemovingNulls.h>

#import "SENAPIClient.h"
#import "SENAuthorizationService.h"

static NSString* const SENDefaultBaseURLPath = @"https://dev-api.hello.is/v1";
static NSString* const SENAPIClientBaseURLPathKey = @"SENAPIClientBaseURLPathKey";
static AFHTTPSessionManager* sessionManager = nil;

@implementation SENAPIClient

typedef void (^SENAFFailureBlock)(NSURLSessionDataTask *, NSError *);
typedef void (^SENAFSuccessBlock)(NSURLSessionDataTask *, id responseObject);
SENAFFailureBlock (^SENAPIClientRequestFailureBlock)(SENAPIDataBlock) = ^SENAFFailureBlock(SENAPIDataBlock completion) {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if ([SENAuthorizationService isAuthorizationError:error]
            && [SENAuthorizationService isAuthorizedRequest:task.originalRequest]) {
            [SENAuthorizationService deauthorize];
        }
        if (completion)
            completion(nil, error);
    };
};

SENAFSuccessBlock (^SENAPIClientRequestSuccessBlock)(SENAPIDataBlock) = ^SENAFSuccessBlock(SENAPIDataBlock completion) {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject) {
            NSData* data = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
            id strippedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil removingNulls:YES ignoreArrays:NO];
            if (completion)
                completion(strippedJSON, nil);
            return;
        }
        if (completion)
            completion(nil, nil);
    };
};

+ (AFHTTPSessionManager*)HTTPSessionManager
{
    if (!sessionManager) {
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
        sessionManager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        //        [sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return sessionManager;
}

+ (NSURL*)baseURL
{
    NSString* cachedPath = [[NSUserDefaults standardUserDefaults] stringForKey:SENAPIClientBaseURLPathKey];
    NSString* baseURLPath = cachedPath.length > 0 ? cachedPath : SENDefaultBaseURLPath;
    return [NSURL URLWithString:baseURLPath];
}

+ (void)resetToDefaultBaseURL
{
    sessionManager = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SENAPIClientBaseURLPathKey];
}

+ (BOOL)setBaseURLFromPath:(NSString*)baseURLPath
{
    NSURL* baseURL = [NSURL URLWithString:baseURLPath];
    if (baseURL && baseURLPath.length > 0) {
        sessionManager = nil;
        if (baseURLPath.length == 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SENAPIClientBaseURLPathKey];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:baseURLPath forKey:SENAPIClientBaseURLPathKey];
        }
        return YES;
    }
    return NO;
}

+ (NSString*)urlEncode:(NSString*)URLString {
    static NSMutableCharacterSet* set = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [[NSMutableCharacterSet alloc] init];
        [set formUnionWithCharacterSet:[NSCharacterSet URLPathAllowedCharacterSet]];
        [set formUnionWithCharacterSet:[NSCharacterSet URLQueryAllowedCharacterSet]];
    });
    return [URLString stringByAddingPercentEncodingWithAllowedCharacters:set];
}

///-------------------------------
/// @name HTTP Requests Formatting
///-------------------------------

+ (NSDictionary *)defaultHTTPHeaderValues
{
    return [[self HTTPSessionManager].requestSerializer HTTPRequestHeaders];
}

+ (void)setValue:(id)value forHTTPHeaderField:(NSString *)fieldName
{
    [[self HTTPSessionManager].requestSerializer setValue:value forHTTPHeaderField:fieldName];
}

///---------------------------
/// @name Making HTTP Requests
///---------------------------

+ (void)GET:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completion
{
    [[self HTTPSessionManager] GET:[self urlEncode:URLString] parameters:parameters
                           success:SENAPIClientRequestSuccessBlock(completion)
                           failure:SENAPIClientRequestFailureBlock(completion)];
}

+ (void)POST:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completion
{
    [[self HTTPSessionManager] POST:[self urlEncode:URLString] parameters:parameters
                            success:SENAPIClientRequestSuccessBlock(completion)
                            failure:SENAPIClientRequestFailureBlock(completion)];
}

+ (void)PUT:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completion
{
    [[self HTTPSessionManager] PUT:[self urlEncode:URLString] parameters:parameters
                           success:SENAPIClientRequestSuccessBlock(completion)
                           failure:SENAPIClientRequestFailureBlock(completion)];
}

+ (void)DELETE:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completion
{
    [[self HTTPSessionManager] DELETE:[self urlEncode:URLString] parameters:parameters
                              success:SENAPIClientRequestSuccessBlock(completion)
                              failure:SENAPIClientRequestFailureBlock(completion)];
}

+ (void)PATCH:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completion
{
    [[self HTTPSessionManager] PATCH:[self urlEncode:URLString] parameters:parameters
                             success:SENAPIClientRequestSuccessBlock(completion)
                             failure:SENAPIClientRequestFailureBlock(completion)];
}

@end
