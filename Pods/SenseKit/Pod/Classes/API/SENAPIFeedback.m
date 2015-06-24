//
//  SENAPIFeedback.m
//  Pods
//
//  Created by Delisa Mason on 12/4/14.
//
//

#import "SENAPIFeedback.h"
#import "SENAPIClient.h"
#import "SENSleepResult.h"

@implementation SENAPIFeedback

+ (NSDateFormatter*)dateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}

+ (void)updateSegment:(SENSleepResultSegment*)segment
             withHour:(NSUInteger)hour
               minute:(NSUInteger)minute
      forNightOfSleep:(NSDate *)sleepDate
           completion:(SENAPIErrorBlock)completion
{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:4];
    NSString* formattedDate = [[self dateFormatter] stringFromDate:sleepDate];
    if (formattedDate)
        params[@"date_of_night"] = formattedDate;
    if (segment.eventType.length > 0)
        params[@"event_type"] = segment.eventType;
    params[@"new_time_of_event"] = [self parameterStringForHour:hour minute:minute];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = segment.timezone;
    NSDateComponents* components = [calendar components:(NSHourCalendarUnit|NSMinuteCalendarUnit) fromDate:segment.date];
    params[@"old_time_of_event"] = [self parameterStringForHour:components.hour minute:components.minute];
    [SENAPIClient POST:@"feedback/sleep" parameters:params completion:^(id data, NSError *error) {
        if (completion)
            completion(error);
    }];
}

+ (NSString*)parameterStringForHour:(NSUInteger)hour minute:(NSUInteger)minute
{
    static NSString* const HEMClockParamFormat = @"%@:%@";
    NSString* hourText = [self stringForNumber:hour];
    NSString* minuteText = [self stringForNumber:minute];
    return [NSString stringWithFormat:HEMClockParamFormat, hourText, minuteText];
}

+ (NSString*)stringForNumber:(NSUInteger)number
{
    static NSString* const HEMNumberParamFormat = @"%ld";
    static NSString* const HEMSmallNumberParamFormat = @"0%ld";
    NSString* format = number <= 9 ? HEMSmallNumberParamFormat : HEMNumberParamFormat;
    return [NSString stringWithFormat:format, (long)number];
}

@end
