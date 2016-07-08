//
//  SENAPIShare.h
//  Pods
//
//  Created by Jimmy Lu on 6/21/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SENShareable;

extern NSString* const SENAPIShareErrorDomain;

typedef NS_ENUM(NSInteger, SENAPIShareError) {
    SENAPIShareErrorInvalidArgument = -1
};

@interface SENAPIShare : NSObject

+ (void)shareURLFor:(id<SENShareable>)shareable
         completion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END