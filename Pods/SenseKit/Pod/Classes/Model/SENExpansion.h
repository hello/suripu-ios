//
//  SENExpansion.h
//  Pods
//
//  Created by Jimmy Lu on 9/27/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@class SENRemoteImage;

typedef NS_ENUM(NSUInteger, SENExpansionState) {
    SENExpansionStateUnknown = 0,
    SENExpansionStateNotConnected,
    SENExpansionStateConnectedOn,
    SENExpansionStateConnectedOff,
    SENExpansionStateRevoked,
    SENExpansionStateNotConfigured
};

@interface SENExpansion : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* identifier;
@property (nonatomic, copy, readonly) NSString* category;
@property (nonatomic, copy, readonly) NSString* deviceName;
@property (nonatomic, copy, readonly) NSString* serviceName;
@property (nonatomic, copy, readonly) NSString* authUri;
@property (nonatomic, copy, readonly) NSString* authCompletionUri;
@property (nonatomic, copy, readonly) NSString* expansionDescription;
@property (nonatomic, strong, readonly) SENRemoteImage* remoteIcon;
@property (nonatomic, assign) SENExpansionState state;

- (NSDictionary*)dictionaryValueForUpdate;

@end

@interface SENExpansionConfig : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* identifier;
@property (nonatomic, copy, readonly) NSString* localizedName;

- (NSDictionary*)dictionaryValue;

@end
