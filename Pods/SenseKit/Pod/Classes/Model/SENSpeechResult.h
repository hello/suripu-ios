//
//  SENSpeechResult.h
//  Pods
//
//  Created by Jimmy Lu on 7/28/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SENSpeechStatus) {
    SENSpeechStatusUnknown = 0,
    SENSpeechStatusOk,
    SENSpeechStatusRejected,
    SENSpeechStatusTryAgain
};

@interface SENSpeechResult : NSObject

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, copy, readonly) NSString* requestText;
@property (nonatomic, copy, readonly) NSString* responseText;
@property (nonatomic, copy, readonly) NSString* command;
@property (nonatomic, assign, readonly) SENSpeechStatus status;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end
