//
//  SENAPIFeedback.m
//  Pods
//
//  Created by Delisa Mason on 12/4/14.
//
//

#import "SENAPIFeedback.h"
#import "SENAPIClient.h"

@implementation SENAPIFeedback

+ (NSDateFormatter*)timeFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm";
    });
    return formatter;
}

+ (NSDateFormatter*)dateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}

+ (void)sendAccurateWakeupTime:(NSDate *)wakeupTime
            detectedWakeupTime:(NSDate *)detectedTime
               forNightOfSleep:(NSDate *)sleepDate
                    completion:(SENAPIErrorBlock)block {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSString* formattedWakeupTime = [[self timeFormatter] stringFromDate:wakeupTime];
    NSString* formattedDetectedTime = [[self timeFormatter] stringFromDate:detectedTime];
    NSString* formattedDate = [[self dateFormatter] stringFromDate:sleepDate];
    if (formattedWakeupTime && ![formattedWakeupTime isEqualToString:formattedDetectedTime]) {
        params[@"hour"] = formattedWakeupTime;
        params[@"good"] = @(NO);
    } else {
        params[@"good"] = @(YES);
    }
    if (formattedDate)
        params[@"day"] = formattedDate;

    [SENAPIClient POST:@"feedback" parameters:params completion:^(id data, NSError *error) {
        if (block)
            block(error);
    }];
}

@end
