
#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <NSJSONSerialization-NSNullRemoval/NSJSONSerialization+RemovingNulls.h>

#import "SENAPIClient.h"
#import "SENAuthorizationService.h"
#import "SENLocalPreferences.h"

NSString* const SENAPIReachableNotification = @"SENAPIReachableNotification";
NSString* const SENAPIUnreachableNotification = @"SENAPIUnreachableNotification";

static NSString* const SENDefaultBaseURLPath = @"https://dev-api.hello.is/v1";
static NSString* const SENAPIClientBaseURLPathKey = @"SENAPIClientBaseURLPathKey";
static NSString* const SENAPIErrorLocalizedMessageKey = @"message";
static AFHTTPSessionManager* sessionManager = nil;

@implementation SENAPIClient

typedef void (^SENAFFailureBlock)(NSURLSessionDataTask *, NSError *);
typedef void (^SENAFSuccessBlock)(NSURLSessionDataTask *, id responseObject);

static NSError* SENParseErrorForData(NSError* error) {
    NSData *data = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (data) {
        id errorData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([errorData isKindOfClass:[NSDictionary class]]) {
            NSString* message = errorData[SENAPIErrorLocalizedMessageKey];
            if ([message isKindOfClass:[NSString class]] && message.length > 0) {
                NSMutableDictionary* userInfo = [error.userInfo mutableCopy];
                userInfo[NSLocalizedDescriptionKey] = message;
                userInfo[NSUnderlyingErrorKey] = error;
                return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
            }
        }
    }
    return error;
}

SENAFFailureBlock (^SENAPIClientRequestFailureBlock)(SENAPIDataBlock) = ^SENAFFailureBlock(SENAPIDataBlock completion) {
    return ^(NSURLSessionDataTask *task, NSError *error) {
        if ([SENAuthorizationService isAuthorizationError:error]
            && [SENAuthorizationService isAuthorizedRequest:task.originalRequest]) {
            [SENAuthorizationService deauthorize];
        }

        if (!completion)
            return;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError* parsedError = SENParseErrorForData(error);
             dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, parsedError);
             });
        });
    };
};

SENAFSuccessBlock (^SENAPIClientRequestSuccessBlock)(SENAPIDataBlock) = ^SENAFSuccessBlock(SENAPIDataBlock completion) {
    return ^(NSURLSessionDataTask *task, id responseObject) {
        if (!completion) return;
        if (responseObject) {
            // parsing JSON can be an expensive operation so moving this work in the bg thread
            // frees up some main thread a bit for other things.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData* data = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
                id strippedJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil removingNulls:YES ignoreArrays:NO];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(strippedJSON, nil);
                });
            });
            return;
        }
        completion(nil, nil);
    };
};

+ (AFHTTPSessionManager*)HTTPSessionManager
{
    if (!sessionManager) {
        sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseURL]];
        sessionManager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        [sessionManager.reachabilityManager startMonitoring];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleReachabilityUpdate:)
                                                     name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return sessionManager;
}

+ (NSURL*)baseURL
{
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSString* cachedPath = [preferences persistentPreferenceForKey:SENAPIClientBaseURLPathKey];
    NSString* baseURLPath = cachedPath.length > 0 ? cachedPath : SENDefaultBaseURLPath;
    return [NSURL URLWithString:baseURLPath];
}

+ (void)resetToDefaultBaseURL
{
    [sessionManager.reachabilityManager stopMonitoring];
    sessionManager = nil;
    [[SENLocalPreferences sharedPreferences] setPersistentPreference:nil forKey:SENAPIClientBaseURLPathKey];
}

+ (BOOL)setBaseURLFromPath:(NSString*)baseURLPath
{
    NSURL* baseURL = [NSURL URLWithString:baseURLPath];
    if (baseURL && baseURLPath.length > 0) {
        [sessionManager.reachabilityManager stopMonitoring];
        sessionManager = nil;
        // why would base url path have length of 0 here?
        [[SENLocalPreferences sharedPreferences] setPersistentPreference:baseURLPath.length == 0 ? nil : baseURLPath
                                                                  forKey:SENAPIClientBaseURLPathKey];
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

+ (void)handleReachabilityUpdate:(NSNotification*)note
{
    AFNetworkReachabilityStatus status = [note.userInfo[AFNetworkingReachabilityNotificationStatusItem] integerValue];
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            // do nothing since this simply means it has not checked
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            [[NSNotificationCenter defaultCenter] postNotificationName:SENAPIReachableNotification object:nil];
            break;
        case AFNetworkReachabilityStatusNotReachable:
        default:
            [[NSNotificationCenter defaultCenter] postNotificationName:SENAPIUnreachableNotification object:nil];
            break;
    }
}

+ (BOOL)isAPIReachable
{
    AFNetworkReachabilityManager* manager = sessionManager.reachabilityManager;
    return [manager isReachable];
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
