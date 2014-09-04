
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"/timeline/%ld-%ld-%ld";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    [[SENAPIClient HTTPSessionManager] GET:[self timelinePathForDate:date] parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        block(responseObject, nil);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        block(nil, error);
    }];
}

+ (NSString*)timelinePathForDate:(NSDate*)date
{
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat, components.year, components.month, components.day];
}

@end
