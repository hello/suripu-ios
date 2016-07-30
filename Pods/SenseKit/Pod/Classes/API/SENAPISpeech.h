//
//  SENAPISpeech.h
//  Pods
//
//  Created by Jimmy Lu on 7/28/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPISpeech : NSObject

/**
 * @discussion
 * Get a list of recent voice commands and the results, if any, from them
 *
 * @param completion: the block to call when results are retrieved
 */
+ (void)getRecentVoiceCommands:(SENAPIDataBlock)completion;

@end
