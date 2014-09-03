
#import <Foundation/Foundation.h>

@interface HEMFakeDataGenerator : NSObject

+ (NSDictionary*)sleepDataForDate:(NSDate*)date;
+ (NSArray*)summarySleepScoresFromDate:(NSDate*)date;
@end
