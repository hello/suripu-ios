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

typedef NS_ENUM(NSUInteger, SENExpansionType) {
    SENExpansionTypeUnknown = 0,
    SENExpansionTypeLights,
    SENExpansionTypeThermostat
};

typedef struct {
    NSInteger min;
    NSInteger max;
    NSInteger setpoint;
} SENExpansionValueRange;

@interface SENExpansion : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSNumber* identifier;
@property (nonatomic, copy, readonly) NSString* deviceName;
@property (nonatomic, copy, readonly) NSString* serviceName;
@property (nonatomic, copy, readonly) NSString* authUri;
@property (nonatomic, copy, readonly) NSString* authCompletionUri;
@property (nonatomic, copy, readonly) NSString* expansionDescription;
@property (nonatomic, strong, readonly) SENRemoteImage* remoteIcon;
@property (nonatomic, assign) SENExpansionState state;
@property (nonatomic, assign) SENExpansionType type;
@property (nonatomic, assign, readonly) SENExpansionValueRange valueRange;

+ (SENExpansionValueRange)valueRangeFromDict:(NSDictionary*)dict;
+ (SENExpansionType)typeFromString:(NSString*)typeString;
+ (NSString*)typeStringFromEnum:(SENExpansionType)type;
+ (NSDictionary*)dictionaryValueFromRange:(SENExpansionValueRange)range;
- (NSDictionary*)dictionaryValueForUpdate;

@end

@interface SENExpansionConfig : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* identifier;
@property (nonatomic, copy, readonly) NSString* localizedName;
@property (nonatomic, assign, readonly, getter=isSelected) BOOL selected;

- (NSDictionary*)dictionaryValue;

@end
