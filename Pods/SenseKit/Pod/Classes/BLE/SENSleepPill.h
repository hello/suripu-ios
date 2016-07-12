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

@interface SENSleepPill : NSObject

@property (nonatomic, strong, readonly) LGPeripheral* peripheral;

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;
- (NSString*)name;
- (NSInteger)rssi;
- (NSString*)identifier;

@end

NS_ASSUME_NONNULL_END