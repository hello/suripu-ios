//
//  SENAPISupport.h
//  Pods
//
//  Created by Jimmy Lu on 6/25/15.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPISupport : NSObject

/**
 * @method supportTopics:
 *
 * @discussion
 * Obtain a list of support topics
 *
 * @param completion: block to invoke when complete
 */
+ (void)supportTopics:(SENAPIDataBlock)completion;

@end
