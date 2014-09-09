
#import <AFNetworking/AFHTTPSessionManager.h>

#import "SENAPIClient.h"

static NSString* const SENDefaultBaseURLPath = @"https://dev-api.hello.is/v1";
//static NSString* const SENDefaultBaseURLPath = @"http://192.168.128.88:9999";
static NSString* const SENAPIClientBaseURLPathKey = @"SENAPIClientBaseURLPathKey";
static AFHTTPSessionManager* sessionManager = nil;

@implementation SENAPIClient

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

@end
