//
//  SENDFUStatus.h
//  Pods
//
//  Created by Jimmy Lu on 7/18/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENDFUState) {
    SENDFUStateUnknown = 1,
    SENDFUStateNotRequired,
    SENDFUStateRequired,
    SENDFUStateRequestSent,
    SENDFUStateInProgress,
    SENDFUStateComplete,
    SENDFUStateError
};

@interface SENDFUStatus : NSObject

@property (nonatomic, assign, readonly) SENDFUState currentState;

- (instancetype)initWithDictionary:(NSDictionary*)response;
- (BOOL)isRequired;
- (BOOL)isInProgress;

@end
