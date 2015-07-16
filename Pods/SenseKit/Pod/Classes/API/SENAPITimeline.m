
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"
#import "SENTimeline.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"v2/timeline/%ld-%02ld-%02ld";
static NSString* const SENAPITimelineEndpoint = @"v2/timeline";
static NSString* const SENAPITimelineErrorDomain = @"is.hello.api.timeline";
static NSString* const SENAPITimelineFeedbackPath = @"events";
static NSString* const SENAPITimelineFeedbackParamNewTime = @"new_event_time";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    NSString* const SENAPITimelineUnparsedErrorFormat = @"Raw timeline could not be parsed: %@";
    if (!block)
        return;
    [SENAPIClient  GET:[self timelinePathForDate:date] parameters:nil completion:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            SENTimeline* timeline = [[SENTimeline alloc] initWithDictionary:data];
            block(timeline, nil);
        } else {
            NSString* description = [NSString stringWithFormat:SENAPITimelineUnparsedErrorFormat, data];
            block(nil, [NSError errorWithDomain:@"is.hello"
                                           code:500
                                       userInfo:@{NSLocalizedDescriptionKey:description}]);
        }
    }];
}

+ (void)verifySleepEvent:(SENTimelineSegment*)sleepEvent
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

+ (void)removeSleepEvent:(SENTimelineSegment*)sleepEvent
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

+ (void)amendSleepEvent:(SENTimelineSegment*)sleepEvent
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
    [SENAPIClient PATCH:path parameters:parameters completion:^(id data, NSError *error) {
        SENTimeline* timeline = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            timeline = [[SENTimeline alloc] initWithDictionary:data];
        }
        if (block)
            block(timeline, error);
    }];

}

#pragma mark - Helpers

+ (NSString*)formattedValueWithHour:(NSNumber*)hour minutes:(NSNumber*)minutes {
    NSString* timeChange = nil;
    if (hour && minutes) {
        static NSString* const HEMClockParamFormat = @"%02ld:%02ld";
        timeChange = [NSString stringWithFormat:HEMClockParamFormat,
                      (long)[hour longValue],
                      (long)[minutes longValue]];
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


+ (NSString*)feedbackPathForDateOfSleep:(NSDate*)dateOfSleep withEvent:(SENTimelineSegment*)event {
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@",
            SENAPITimelineEndpoint,
            [[self dateFormatter] stringFromDate:dateOfSleep],
            SENAPITimelineFeedbackPath,
            SENTimelineSegmentTypeNameFromType([event type]),
            [self timestampForDate:[event date]]];
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
