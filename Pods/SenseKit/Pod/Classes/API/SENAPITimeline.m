
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"timeline/%ld-%ld-%ld";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    [SENAPIClient  GET:[self timelinePathForDate:date] parameters:nil completion:block];
}

+ (NSString*)timelinePathForDate:(NSDate*)date
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat, (long)components.year, (long)components.month, (long)components.day];
}

@end
