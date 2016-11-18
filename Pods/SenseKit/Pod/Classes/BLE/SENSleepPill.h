//
//  SENSleepPill.h
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//

#import <Foundation/Foundation.h>

@class LGPeripheral;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SENSleepPillAdvertisedVersion) {
    SENSleepPillAdvertisedVersionUnknown = 0,
    SENSleepPillAdvertisedVersionOneFive
};

@interface SENSleepPill : NSObject

@property (nonatomic, strong, readonly) LGPeripheral* peripheral;
@property (nonatomic, assign, readonly) SENSleepPillAdvertisedVersion version;

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;
- (NSString*)name;
- (NSInteger)rssi;
- (NSString*)identifier;

@end

NS_ASSUME_NONNULL_END