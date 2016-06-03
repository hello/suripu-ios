//
//  HEMNameChangePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/21/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNameChangePresenter.h"
#import "HEMAccountService.h"

typedef NS_ENUM(NSUInteger, HEMNameChangeRow) {
    HEMNameChangeRowFirstName = 0,
    HEMNameChangeRowLastName,
    HEMNameChangeRowCount
};

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
    return HEMNameChangeRowCount;
}

- (BOOL)canEnableSave:(NSDictionary*)formContent {
    NSString* firstName = formContent[[self placeHolderTextForFieldInRow:HEMNameChangeRowFirstName]];
    return [firstName length] > 0;
}

- (NSString*)existingTextForFieldInRow:(NSInteger)row {
    SENAccount* account = [[self accountService] account];
    switch (row) {
        default:
        case HEMNameChangeRowFirstName:
            return [account firstName];
        case HEMNameChangeRowLastName:
            return [account lastName];
    }
}

- (NSString*)placeHolderTextForFieldInRow:(NSInteger)row {
    switch (row) {
        default:
        case HEMNameChangeRowFirstName:
            return NSLocalizedString(@"onboarding.account.firstname", nil);
        case HEMNameChangeRowLastName:
            return NSLocalizedString(@"onboarding.account.lastname", nil);
    }
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
    NSString* firstName = content[[self placeHolderTextForFieldInRow:HEMNameChangeRowFirstName]];
    NSString* lastName = content[[self placeHolderTextForFieldInRow:HEMNameChangeRowLastName]];
    [[self accountService] updateFirstName:firstName lastName:lastName completion:^(NSError * _Nullable error) {
        NSString* errorMessage = nil;
        if (error) {
            errorMessage = [weakSelf errorMessageForError:error];
        } else {
            [SENAnalytics track:HEMAnalyticsEventChangeName];
        }
        completion (errorMessage);
    }];
}

@end
