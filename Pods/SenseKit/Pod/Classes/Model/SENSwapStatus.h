//
//  SENUpgradeStatus.h
//  Pods
//
//  Created by Jimmy Lu on 8/25/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

typedef NS_ENUM(NSUInteger, SENSwapResponse) {
    SENSwapResponseOk = 0,
    SENSwapResponseTooManyDevices, // should never happen to normal users
    SENSwapResponsePairedToAnother // if new Sense is currently paired to a different account
};

@interface SENSwapStatus : NSObject <SENSerializable>

@property (nonatomic, assign, readonly) SENSwapResponse response;

@end
