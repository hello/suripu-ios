#import <AFNetworking/AFURLResponseSerialization.h>
#import "HEMHTTPErrorHandler.h"

@implementation HEMHTTPErrorHandler

+ (void)showAlertForHTTPError:(NSError*)error withTitle:(NSString*)errorTitle
{
    NSString* errorMessage = nil;
    NSHTTPURLResponse* response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    if (response) {
        errorMessage = [self errorMessageForStatusCode:response.statusCode];
    }
    if (!errorMessage) {
        errorMessage = error.localizedDescription ?: NSLocalizedString(@"sign-up.error.generic", nil);
    }
    [[[UIAlertView alloc] initWithTitle:errorTitle
                                message:errorMessage
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"actions.ok", nil), nil] show];
}

+ (NSString*)errorMessageForStatusCode:(NSInteger)statusCode
{
    switch (statusCode) {
    case 401:
        return NSLocalizedString(@"authorization.sign-in.failed.message", nil);
    case 409:
        return NSLocalizedString(@"sign-up.error.conflict", nil);
    default:
        return nil;
    }
}

@end
