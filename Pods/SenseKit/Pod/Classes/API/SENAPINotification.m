
#import <UIKit/UIKit.h>
#import "SENAPIClient.h"
#import "SENAPINotification.h"
#import "SENNotificationSetting.h"

@implementation SENAPINotification

static NSString* const SENAPINotificationErrorDomain = @"is.hello.sense.api.notification";
static NSString* const SENAPINotificationEndpoint = @"v1/notifications";
static NSString* const SENAPINotificationRegistrationEndpoint = @"registration";
static NSString* const SENAPINotificationOS = @"ios";

+ (void)registerForRemoteNotificationsWithTokenData:(NSData*)tokenData completion:(void (^)(NSError*))completion {
    NSString* token = [self hexadecimalStringForData:tokenData];
    if (!token) {
        if (completion) {
            completion ([NSError errorWithDomain:SENAPINotificationErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }
    
    NSString* osVersion = [[UIDevice currentDevice] systemVersion];
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSDictionary* parameters = @{
        @"token" : token,
        @"os" : SENAPINotificationOS,
        @"version" : osVersion,
        @"app_version" : appVersion
    };
    
    NSString* path = [SENAPINotificationEndpoint stringByAppendingPathComponent:SENAPINotificationRegistrationEndpoint];
    [SENAPIClient POST:path parameters:parameters completion:^(id data, NSError* error) {
        if (completion)
            completion(error);
    }];
}

+ (void)getNotificationSettings:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPINotificationEndpoint parameters:nil completion:^(id data, NSError *error) {
        if (completion) {
            completion ([self settingsFromResponse:data], error);
        }
    }];
}

+ (void)updateSettings:(NSArray<SENNotificationSetting*>*)settings completion:(SENAPIDataBlock)completion {
    NSMutableArray* parameters = [NSMutableArray arrayWithCapacity:[settings count]];
    for (SENNotificationSetting* setting in settings) {
        [parameters addObject:[setting dictionaryValue]];
    }
    [SENAPIClient PUT:SENAPINotificationEndpoint parameters:parameters completion:completion];
}

#pragma mark - Convenience methods

+ (NSArray<SENNotificationSetting*>*)settingsFromResponse:(id)data {
    NSMutableArray* settings = nil;
    if ([data isKindOfClass:[NSArray class]]) {
        settings = [NSMutableArray arrayWithCapacity:[data count]];
        for (id obj in data) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                SENNotificationSetting* setting = [[SENNotificationSetting alloc] initWithDictionary:obj];
                if (setting) {
                    [settings addObject:setting];
                }
            }
        }
    }
    return settings;
}

/**
 *  A hexadecimal representation of data value
 */
+ (NSString*)hexadecimalStringForData:(NSData*)data {
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
