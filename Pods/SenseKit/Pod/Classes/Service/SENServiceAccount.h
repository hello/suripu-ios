//
//  SENServiceAccount.h
//  Pods
//
//  Created by Jimmy Lu on 12/5/14.
//
//

#import "SENService.h"

typedef void(^SENAccountResponseBlock)(NSError* error);

typedef NS_ENUM(NSUInteger, SENServiceAccountError) {
    SENServiceAccountErrorInvalidArg = 1
};

@class SENAccount;

@interface SENServiceAccount : SENService

@property (nonatomic, strong, readonly) SENAccount* account;

/**
 * @return a shared instance of the account service
 */
+ (id)sharedService;

/**
 * @method refreshAccount:
 *
 * @discussion:
 * This will load / refresh the current account property.  By default, the
 * account property is nil until this is called at least once
 */
- (void)refreshAccount:(SENAccountResponseBlock)completion;

/**
 * Change the password for the currently signed in account by providing the
 * current password and the new password.  This will additionally re-authorize
 * the user using the latest password
 *
 * @param currentPassword: the current password used for the account
 * @param password:        the new password
 * @param completion:      optional block to invoke when all is done
 */
- (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
            completion:(SENAccountResponseBlock)completion;

/**
 * @method changeEmail:completion
 *
 * @discussion
 * Update the email of the currently signed in user.  This will force a refresh
 * of the account as it will require the lastest information to update the email
 * 
 * @param email: the new email to be used
 * @param completion: the block to invoke when all is done
 */
- (void)changeEmail:(NSString*)email completion:(SENAccountResponseBlock)completion;

@end
