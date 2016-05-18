//
//  HEMNameChangePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNameChangePresenter.h"
#import "HEMAccountService.h"

@interface HEMNameChangePresenter()

@property (nonatomic, weak) HEMAccountService* accountService;

@end

@implementation HEMNameChangePresenter

- (instancetype)initWithAccountService:(HEMAccountService*)accountService {
    self = [super init];
    if (self) {
        _accountService = accountService;
    }
    return self;
}

- (NSUInteger)numberOfFields {
    return 1;
}

- (NSString*)existingTextForFieldInRow:(NSInteger)row {
    SENAccount* account = [[self accountService] account];
    return [account name];
}

- (NSString*)placeHolderTextForFieldInRow:(NSInteger)row {
    return NSLocalizedString(@"settings.account.name.placeholder", nil);
}

- (NSString*)errorMessageForError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMAccountServiceDomain]) {
        switch ([error code]) {
            case HEMAccountServiceErrorAccountNotUpToDate:
                return NSLocalizedString(@"settings.account.update.account-not-up-to-date", nil);
            case HEMAccountServiceErrorNameTooLong:
                return NSLocalizedString(@"settings.account.update.name-too-long", nil);
            case HEMAccountServiceErrorNameTooShort:
                return NSLocalizedString(@"settings.account.update.name-too-short", nil);
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
    NSString* updatedName = [content objectForKey:[self placeHolderTextForFieldInRow:0]];
    [[self accountService] updateName:updatedName completion:^(NSError * _Nullable error) {
        NSString* errorMessage = nil;
        if (error) {
           errorMessage = [weakSelf errorMessageForError:error];
        }
        completion (errorMessage);
    }];
}

@end
