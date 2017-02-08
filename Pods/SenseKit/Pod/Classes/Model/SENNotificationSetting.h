//
//  SENNotificationSetting.h
//  Pods
//
//  Created by Jimmy Lu on 2/3/17.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

typedef NS_ENUM(NSInteger, SENNotificationType) {
    SENNotificationTypeUnknown = 0,
    SENNotificationTypeSleepScore,
    SENNotificationTypeSystem,
    SENNotificationTypeSleepReminder
};

NS_ASSUME_NONNULL_BEGIN

@interface SENNotificationSchedule: NSObject <SENSerializable>

@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

- (nullable instancetype)initWithDictionary:(NSDictionary *)data;
- (instancetype)initWithHour:(NSInteger)hour minute:(NSInteger)minute;
- (NSDictionary*)dictionaryValue;

@end


@interface SENNotificationSetting : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* localizedName;
@property (nonatomic, assign, readonly) SENNotificationType type;
@property (nonatomic, strong, nullable) SENNotificationSchedule* schedule;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

- (nullable instancetype)initWithDictionary:(NSDictionary *)data;
- (NSDictionary*)dictionaryValue;

@end

NS_ASSUME_NONNULL_END
