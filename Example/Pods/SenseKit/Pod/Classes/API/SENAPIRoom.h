
#import <Foundation/Foundation.h>

typedef void (^SENAPIDataBlock)(id data, NSError* error);

@interface SENAPIRoom : NSObject

/**
 *  GET /room/current
 *
 *  Fetch the current room conditions as an array of sensor data
 *
 *  @param completion block invoked when the network call is completed asynchronously
 */
+ (void)currentWithCompletion:(SENAPIDataBlock)completion;
@end
