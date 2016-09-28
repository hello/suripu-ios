//
//  HEMPasswordChangePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 12/22/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPasswordChangePresenter.h"
#import "HEMAccountService.h"

@interface HEMPasswordChangePresenter()

@property (nonatomic, weak) HEMAccountService* accountService;

@end

@implementation HEMPasswordChangePresenter

- (instancetype)initWithAccountService:(HEMAccountService*)accountService {
    self = [super init];
    if (self) {
        _accountService = accountService;
    }
    return self;
}

- (BOOL)isFieldSecureInRow:(NSInteger)row {
    return YES;
}

- (NSUInteger)numberOfFields {
    return 3;
}

- (UITextAutocapitalizationType)fieldCapitalizationTypeInRow:(NSInteger)row {
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)fieldAutocorrectTypeInRow:(NSInteger)row {
    return UITextAutocorrectionTypeNo;
}

- (NSString*)placeHolderTextForFieldInRow:(NSInteger)row {
    switch (row) {
        case 0:
            return NSLocalizedString(@"settings.account.password-current.placeholder", nil);
        case 1:
            return NSLocalizedString(@"settings.account.password-new.placeholder", nil);
        case 2:
            return NSLocalizedString(@"settings.account.password-new-confirm.placeholder", nil);
        default:
            return nil;
    }
}

- (NSString*)errorMessageForError:(NSError*)error {
    if ([[error domain] isEqualToString:HEMAccountServiceDomain]) {
        switch ([error code]) {
            case HEMAccountServiceErrorInvalidArg:
                return NSLocalizedString(@"settings.account.update.failure", nil);
            case HEMAccountServiceErrorPasswordTooShort:
                return NSLocalizedString(@"settings.account.password-too-short", nil);
            case HEMAccountServiceErrorPasswordInsecure:
                return NSLocalizedString(@"settings.account.password-insecure", nil);
            case HEMAccountServiceErrorPasswordNotRecognized:
                return NSLocalizedString(@"settings.account.password.current-password-wrong", nil);
            case HEMAccountServiceErrorAccountNotUpToDate:
                return NSLocalizedString(@"settings.account.update.account-not-up-to-date", nil);
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
    NSString* currentPassword = [content objectForKey:[self placeHolderTextForFieldInRow:0]];
    NSString* newPassword = [content objectForKey:[self placeHolderTextForFieldInRow:1]];
    NSString* confirmPassword = [content objectForKey:[self placeHolderTextForFieldInRow:2]];
    
    if (![newPassword isEqualToString:confirmPassword]) {
        if (completion) {
            completion (NSLocalizedString(@"settings.account.password.does-not-match", nil));
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[self accountService] updatePassword:currentPassword newPassword:newPassword completion:^(NSError * _Nullable error) {
        NSString* errorMessage = nil;
        if (error) {
            errorMessage = [weakSelf errorMessageForError:error];
        } else {
            [SENAnalytics track:HEMAnalyticsEventChangePass];
        }
        completion (errorMessage);
    }];
}

@end
