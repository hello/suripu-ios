//
//  HEMEmailChangePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMEmailChangePresenter.h"
#import "HEMAccountService.h"

@interface HEMEmailChangePresenter()

@property (nonatomic, weak) HEMAccountService* accountService;

@end

@implementation HEMEmailChangePresenter

- (instancetype)initWithAccountService:(HEMAccountService*)accountService {
    self = [super init];
    if (self) {
        _accountService = accountService;
    }
    return self;
}

- (UIKeyboardType)keyboardTypeForFieldInRow:(NSInteger)row {
    return UIKeyboardTypeEmailAddress;
}

- (NSUInteger)numberOfFields {
    return 1;
}

- (NSString*)existingTextForFieldInRow:(NSInteger)row {
    SENAccount* account = [[self accountService] account];
    return [account email];
}

- (NSString*)placeHolderTextForFieldInRow:(NSInteger)row {
    return NSLocalizedString(@"settings.account.email.placeholder", nil);
}

- (NSString*)errorMessageForError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMAccountServiceDomain]) {
        switch ([error code]) {
            case HEMAccountServiceErrorAccountNotUpToDate:
                return NSLocalizedString(@"settings.account.update.account-not-up-to-date", nil);
            case HEMAccountServiceErrorEmailAlreadyExists:
                return NSLocalizedString(@"settings.account.update.email-already-exists", nil);
            case HEMAccountServiceErrorEmailInvalid:
                return NSLocalizedString(@"settings.account.update.email-invalid", nil);
            case HEMAccountServiceErrorServerFailure:
            case HEMAccountServiceErrorUnknown:
            default:
                return NSLocalizedString(@"account.update.error.generic", nil);
        }
    } else if ([[error domain] isEqualToString:NSURLErrorDomain]){
        return [error localizedDescription];
    } else {
        return NSLocalizedString(@"account.update.error.generic", nil);
    }
}

- (void)saveContent:(NSDictionary*)content completion:(HEMFormSaveHandler)completion {
    __weak typeof(self) weakSelf = self;
    NSString* updatedEmail = [content objectForKey:[self placeHolderTextForFieldInRow:0]];
    [[self accountService] updateEmail:updatedEmail completion:^(NSError * _Nullable error) {
        NSString* errorMessage = nil;
        if (error) {
            errorMessage = [weakSelf errorMessageForError:error];
        }
        completion (errorMessage);
    }];
}

@end
