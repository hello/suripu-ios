//
//  SENAPIFeature.h
//  Pods
//
//  Created by Jimmy Lu on 8/4/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@interface SENAPIFeature : NSObject

+ (void)getFeatures:(SENAPIDataBlock)completion;

@end
