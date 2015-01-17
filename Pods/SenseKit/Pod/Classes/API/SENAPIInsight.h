//
//  SENAPIInsight.h
//  Pods
//
//  Created by Jimmy Lu on 10/28/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSInteger, SENAPIInsightError) {
    SENAPIInsightErrorInvalidArgument = -1
};

@class SENInsight;

@interface SENAPIInsight : NSObject

/**
 * @method getInsights:
 *
 * @discussion
 * Get insights from the server, which will return an array of 0...N insight
 * objects.
 *
 * @param completion: the block to invoke when done
 */
+ (void)getInsights:(SENAPIDataBlock)completion;

/**
 * @method getInfoForInsight:completion
 *
 * @discussion
 * Get SENInsightInfo for the particular insight specified.  If insight is not defined or
 * the category of the insight is missing, a SENAPIInsightErrorInvalidArgument error
 * is returned and a request will not be made.
 *
 * @param insight: the insight to retrieve info for
 * @Param completion: the block to invoke when it's been retrieved or error encountered
 */
+ (void)getInfoForInsight:(SENInsight*)insight completion:(SENAPIDataBlock)completion;

@end
