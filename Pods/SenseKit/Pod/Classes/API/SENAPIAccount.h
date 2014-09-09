
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENAccount;

@interface SENAPIAccount : NSObject

/**
 *  Create a new account via the Sense API. Does not require authentication.
 *
 *  @param name            full name of the new user
 *  @param emailAddress    email address
 *  @param password        password
 *  @param completionBlock block invoked when asynchonous call completes
 */
+ (void)createAccountWithName:(NSString*)name
                 emailAddress:(NSString*)emailAddress
                     password:(NSString*)password
                   completion:(SENAPIDataBlock)completionBlock;

/**
 * Override the existing account information for the associated user.
 * 
 * Requires authentication.
 *
 * @param account    existing account for the user
 * @param completion block invoked when asynchronous call completes
 */
+ (void)updateAccount:(SENAccount*)account
      completionBlock:(SENAPIDataBlock)completion;

@end
