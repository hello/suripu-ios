//
//  SENServiceAccount.h
//  Pods
//
//  Created by Jimmy Lu on 12/5/14.
//
//

#import "SENService.h"

typedef void(^SENAccountResponseBlock)(NSError* error);

@interface SENServiceAccount : SENService

+ (id)sharedService;

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

@end
