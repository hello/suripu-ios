//
//  SENAPISystemAlerts.h
//  Pods
//
//  Created by Jimmy Lu on 11/8/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface SENAPISystemAlerts : NSObject

+ (void)getSystemAlerts:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END