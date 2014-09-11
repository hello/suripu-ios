
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPITimeline : NSObject

/**
 *  GET /timeline/:day
 *
 *  Fetch the timeline data for a given date
 *
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)timelineForDate:(NSDate*)date completion:(SENAPIDataBlock)block;

@end
