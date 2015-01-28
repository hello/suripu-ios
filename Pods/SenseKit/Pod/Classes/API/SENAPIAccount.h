
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSUInteger, SENAPIAccountError) {
    SENAPIAccountErrorUnknown = 0,
    SENAPIAccountErrorInvalidArgument = 1,
    SENAPIAccountErrorNameTooShort = 2,
    SENAPIAccountErrorNameTooLong = 3,
    SENAPIAccountErrorEmailInvalid = 4,
    SENAPIAccountErrorPasswordInsecure = 5,
    SENAPIAccountErrorPasswordTooShort = 6,
};

extern NSString* const kSENAccountNotificationAccountCreated;
extern NSString* const SENAPIAccountErrorMessagePasswordTooShort;

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

/**
 * Get an instance of a SENAccount object for the currently authorized user.
 * If the user is not authorized / signed in, the object will be nil
 *
 * @param completion block invoked when asynchronous call completes
 */
+ (void)getAccount:(SENAPIDataBlock)completion;

/**
 * Change the current password to a password specified.  New password will still
 * be require to meet minimum requirements.  Because changing the password will
 * invalidate all access tokens, for all applications / devices, caller must
 * re-authorize the user to ensure continue use of the account.
 * 
 * @param currentPassword: current password of the account
 * @param password:        new password to replace current password
 * @param completion:      optional block to invoke when this done.
 */
+ (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
       completionBlock:(SENAPIDataBlock)completion;

/**
 * Change the email for the specified account.  The email in the account object
 * is a
 * 
 * @param email: the new email to be used instead, which will still undergo
 *               various validation.
 */
+ (void)changeEmailInAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion;

/**
 * Convenience method to translate the api response error in to one of the API
 * error enums.  If the error does not contain any associated response data,
 * SENAPIAccountErrorUnknown is returned
 *
 * @param error: error object from the account api calls
 * @return SENAPIAccountError
 */
+ (SENAPIAccountError)errorForAPIResponseError:(NSError*)error;

@end
