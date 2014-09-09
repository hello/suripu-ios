
#import <Foundation/Foundation.h>

/**
 *  Notification sent when a user is authorized
 */
extern NSString* const SENAuthorizationServiceDidAuthorizeNotification;

/**
 *  Notification sent when a user is deauthorized
 */
extern NSString* const SENAuthorizationServiceDidDeauthorizeNotification;

@interface SENAuthorizationService : NSObject

/**
 *  Sends a request for a new access token, saving the returned credentials to the keychain.
 *  Future requests have the access token in the response set as the authorization header.
 *
 *  @param username the username of the entity to authorize
 *  @param password the password for the given username
 *  @param block    a block invoked after the authentication attempt is completed
 */
+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError* error))block;

/**
 *  Load any cached credentials for use in API requests
 */
+ (void)authorizeRequestsFromKeychain;

/**
 *  Deauthorize future requests and remove the active credentials from the keychain.
 */
+ (void)deauthorize;

/**
 *  Check whether there are cached credentials in the keychain
 */
+ (BOOL)isAuthorized;

/**
 * The access token of the authorized user, if authorized
 * @return the access token or nil if not authorized
 */
+ (NSString*)accessToken;

@end
