
#import <Foundation/Foundation.h>

@interface HEMHTTPErrorHandler : NSObject

/**
 *  Show an alert with a message based on the content of the error
 *
 *  @param error      error to parse
 *  @param errorTitle title of the alert
 */
+ (void)showAlertForHTTPError:(NSError*)error withTitle:(NSString*)errorTitle;
@end
