
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENSleepResultSegmentDepth) {
    SENSleepResultSegmentDepthAwake = 0,
    SENSleepResultSegmentDepthLight = 1,
    SENSleepResultSegmentDepthMedium = 2,
    SENSleepResultSegmentDepthDeep = 3,
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
@property (strong) NSArray* sensors;
@property SENSleepResultSegmentDepth sleepDepth;
@end

@interface SENSleepResultSegmentSensor : NSObject <NSCoding, SENSleepResultSerializable>

@property (strong) NSString* name;
@property (strong) NSNumber* value;
@property (strong) NSString* unit;
@end
