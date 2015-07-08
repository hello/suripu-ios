
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"
#import "SENSleepResult.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"v1/timeline/%ld-%ld-%ld"; // deprecated
static NSString* const SENAPITimelineEndpoint = @"v2/timeline";
static NSString* const SENAPITimelineErrorDomain = @"is.hello.api.timeline";
static NSString* const SENAPITimelineFeedbackPath = @"events";
static NSString* const SENAPITimelineFeedbackParamNewTime = @"new_event_time";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    [SENAPIClient  GET:[self timelinePathForDate:date] parameters:nil completion:block];
}

+ (void)verifySleepEvent:(SENSleepResultSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    [SENAPIClient PUT:path parameters:nil completion:block];
}

+ (void)removeSleepEvent:(SENSleepResultSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    [SENAPIClient DELETE:path parameters:nil completion:block];
}

+ (void)amendSleepEvent:(SENSleepResultSegment*)sleepEvent
         forDateOfSleep:(NSDate*)date
               withHour:(NSNumber*)hour
             andMinutes:(NSNumber*)minutes
             completion:(SENAPIDataBlock)block
{
    
    if (!sleepEvent || !hour || !minutes) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    NSString* formattedTime = [self formattedValueWithHour:hour minutes:minutes];
    NSDictionary* parameters = @{SENAPITimelineFeedbackParamNewTime : formattedTime};
    [SENAPIClient PATCH:path parameters:parameters completion:block];
    
}

#pragma mark - Helpers

+ (NSString*)formattedValueWithHour:(NSNumber*)hour minutes:(NSNumber*)minutes {
    NSString* timeChange = nil;
    if (hour && minutes) {
        static NSString* const HEMClockParamFormat = @"%@:%@";
        NSString* hourText = [self stringForNumber:[hour integerValue]];
        NSString* minuteText = [self stringForNumber:[minutes integerValue]];
        timeChange = [NSString stringWithFormat:HEMClockParamFormat, hourText, minuteText];
    }
    return timeChange;
}

+ (NSNumber*)timestampForDate:(NSDate*)date {
    if (date == nil) {
        return nil;
    }
    return @([date timeIntervalSince1970] * 1000);
}

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


+ (NSString*)feedbackPathForDateOfSleep:(NSDate*)dateOfSleep withEvent:(SENSleepResultSegment*)event {
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@",
            SENAPITimelineEndpoint,
            [[self dateFormatter] stringFromDate:dateOfSleep],
            SENAPITimelineFeedbackPath,
            [event eventType],
            [self timestampForDate:[event date]]];
}

+ (NSString*)stringForNumber:(NSUInteger)number {
    static NSString* const HEMNumberParamFormat = @"%ld";
    static NSString* const HEMSmallNumberParamFormat = @"0%ld";
    NSString* format = number <= 9 ? HEMSmallNumberParamFormat : HEMNumberParamFormat;
    return [NSString stringWithFormat:format, (long)number];
}

+ (NSString*)timelinePathForDate:(NSDate*)date
{
    NSString* calendarId = NSCalendarIdentifierGregorian;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarId];
    NSCalendarUnit flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat,
            (long)components.year, (long)components.month, (long)components.day];
}

@end
