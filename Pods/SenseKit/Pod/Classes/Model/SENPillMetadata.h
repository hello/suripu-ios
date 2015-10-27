//
//  SENPillMetadata.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "SENDeviceMetadata.h"

typedef NS_ENUM(NSUInteger, SENPillColor) {
    SENPillColorUnknown = 0,
    SENPillColorBlue = 1,
    SENPillColorRed = 2
};

typedef NS_ENUM(NSUInteger, SENPillState) {
    SENPillStateUnknown = 0,
    SENPillStateNormal = 1,
    SENPillStateLowBattery = 2
};

@interface SENPillMetadata : SENDeviceMetadata

@property (nonatomic, assign, readonly) SENPillState state;
@property (nonatomic, assign, readonly) SENPillColor color;
@property (nonatomic, strong, readonly, nullable) NSNumber* batteryLevel;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dict;

@end
