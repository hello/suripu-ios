//
//  SENAPIInsight.h
//  Pods
//
//  Created by Jimmy Lu on 10/28/14.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

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

@end
