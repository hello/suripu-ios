
#import <Foundation/Foundation.h>
#import "SENSensor.h"

typedef NS_ENUM(NSInteger, SENSleepResultSegmentDepth) {
    SENSleepResultSegmentDepthAwake = 0,
    SENSleepResultSegmentDepthLight = 40,
    SENSleepResultSegmentDepthMedium = 70,
    SENSleepResultSegmentDepthDeep = 100,
};

@protocol SENSleepResultSerializable <NSObject>

/**
 *  Generate an object, populating properties from a dictionary
 *
 *  @param data data representing object properties
 */
- (instancetype)initWithDictionary:(NSDictionary*)data;

/**
 *  Updates an object, populating properties from a dictionary while
 *  ignoring missing values
 *
 *  @param data data representing object properties
 */
- (void)updateWithDictionary:(NSDictionary*)data;

@end

@interface SENSleepResult : NSObject <NSCoding, SENSleepResultSerializable>

+ (instancetype)sleepResultForDate:(NSDate*)date;

@property (strong) NSDate* date;
@property (strong) NSNumber* score;
@property (strong) NSString* message;
@property (strong) NSArray* segments;
@property (strong) NSArray* sensorInsights;

/**
 *  Persist changes
 */
- (void)save;
@end

@interface SENSleepResultSegment : NSObject <NSCoding, SENSleepResultSerializable>

@property (strong) id serverID;
@property (strong) NSDate* date;
@property (strong) NSNumber* duration;
@property (strong) NSString* message;
@property (strong) NSString* eventType;
@property NSInteger sleepDepth;
@end

@interface SENSleepResultSensorInsight : NSObject <NSCoding, SENSleepResultSerializable>

@property (strong) NSString* name;
@property (strong) NSString* message;
@property SENSensorCondition condition;
@end
