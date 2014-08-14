
#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

typedef void (^SENAPIDataBlock)(id data, NSError* error);

@interface SENAPIClient : NSObject

/**
 *  A convenience helper for making requests through an NSURLSession
 */
+ (AFHTTPSessionManager*)HTTPSessionManager;

/**
 *  The base URL for the suripu app service
 */
+ (NSURL*)baseURL;

/**
 *  Updates the base URL for the suripu app service
 *  @returns YES if the base path was successfully changed
 */
+ (BOOL)setBaseURLFromPath:(NSString*)baseURLPath;

/**
 *  Updates the base URL for the suripu app service to the default URL
 */
+ (void)resetToDefaultBaseURL;

@end
