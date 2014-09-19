
#import <UIKit/UIKit.h>
#import "SENAPIClient.h"
#import "SENAPINotification.h"

@implementation SENAPINotification

static NSString* const SENAPINotificationRegistrationEndpoint = @"notifications/registration";
static NSString* const SENAPINotificationOS = @"ios";

+ (void)registerForRemoteNotificationsWithTokenData:(NSData*)tokenData completion:(void (^)(NSError*))completion
{
    NSString* token = [self hexadecimalStringForData:tokenData];
    if (!token)
        return;
    NSString* osVersion = [[UIDevice currentDevice] systemVersion];
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSDictionary* parameters = @{
        @"token" : token,
        @"os" : SENAPINotificationOS,
        @"version" : osVersion,
        @"app_version" : appVersion
    };
    [SENAPIClient POST:SENAPINotificationRegistrationEndpoint parameters:parameters completion:^(id data, NSError* error) {
        if (completion)
            completion(error);
    }];
}

/**
 *  A hexadecimal representation of data value
 */
+ (NSString*)hexadecimalStringForData:(NSData*)data
{
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];

    if (!dataBuffer)
        return [NSString string];

    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];

    return [NSString stringWithString:hexString];
}

@end