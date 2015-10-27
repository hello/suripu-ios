//
//  SENSenseMetadata.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "SENDeviceMetadata.h"

typedef NS_ENUM(NSUInteger, SENSenseColor) {
    SENSenseColorUnknown = 0,
    SENSenseColorCharcoal = 1,
    SENSenseColorCotton = 2
};

typedef NS_ENUM(NSUInteger, SENSenseState) {
    SENSenseStateUnknown = 0,
    SENSenseStateNormal = 1
};

typedef NS_ENUM(NSUInteger, SENWiFiCondition) {
    SENWiFiConditionNone = 0,
    SENWiFiConditionBad = 1,
    SENWiFiConditionFair = 2,
    SENWiFiConditionGood = 3
};

@interface SENSenseWiFiInfo : NSObject

@property (nonatomic, copy, readonly, nullable)   NSString* ssid;
@property (nonatomic, strong, readonly, nullable) NSNumber* rssi;
@property (nonatomic, strong, readonly, nullable) NSDate* lastUpdated;
@property (nonatomic, assign, readonly) SENWiFiCondition condition;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dict;

@end

@interface SENSenseMetadata : SENDeviceMetadata

@property (nonatomic, assign, readonly) SENSenseState state;
@property (nonatomic, assign, readonly) SENSenseColor color;
@property (nonatomic, strong, readonly, nonnull) SENSenseWiFiInfo* wiFi;

@end
