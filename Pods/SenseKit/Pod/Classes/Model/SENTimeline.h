
#import <Foundation/Foundation.h>
#import "SENCondition.h"
#import "SENTimelineSegment.h"
#import "SENTimelineMetric.h"
#import "SENSerializable.h"

extern NSInteger const SENTimelineSentinelValue;

@interface SENTimeline : NSObject <NSCoding, SENSerializable>

+ (instancetype)timelineForDate:(NSDate*)date;

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* score;
@property (nonatomic) SENCondition scoreCondition;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSArray* segments;
@property (nonatomic, strong) NSArray* metrics;

/**
 *  Persist changes
 */
- (void)save;
@end
