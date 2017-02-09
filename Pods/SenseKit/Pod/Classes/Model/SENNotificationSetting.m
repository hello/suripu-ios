//
//  SENNotificationSetting.m
//  Pods
//
//  Created by Jimmy Lu on 2/3/17.
//
//

#import "SENNotificationSetting.h"
#import "Model.h"

@interface SENNotificationSchedule()

@end

@implementation SENNotificationSchedule

static NSString* kSENScheduleParamHour = @"hour";
static NSString* kSENScheduleParamMinute = @"minute";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    NSNumber* hourObject = SENObjectOfClass(data[kSENScheduleParamHour], [NSNumber class]);
    NSNumber* minuteObject = SENObjectOfClass(data[kSENScheduleParamMinute], [NSNumber class]);
    if (!hourObject || !minuteObject) {
        return nil;
    }
    
    return [self initWithHour:[hourObject integerValue] minute:[minuteObject integerValue]];
}

- (instancetype)initWithHour:(NSInteger)hour minute:(NSInteger)minute {
    if (self = [super init]) {
        _hour = hour;
        _minute = minute;
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{kSENScheduleParamHour: @([self hour]),
             kSENScheduleParamMinute: @([self minute])};
}

@end

@interface SENNotificationSetting()

@property (nonatomic, copy) NSString* typeString;
@property (nonatomic, copy) NSString* localizedName;
@property (nonatomic, assign) SENNotificationType type;

@end

@implementation SENNotificationSetting

static NSString* kSENSettingName = @"name";
static NSString* kSENSettingType = @"type";
static NSString* kSENSettingEnabled = @"enabled";
static NSString* kSENSettingSchedule = @"schedule";

static NSString* kSENSettingTypeSleepScore = @"SLEEP_SCORE";
static NSString* kSENSettingTypeSystem = @"SYSTEM";
static NSString* kSENSettingTypeSleepReminder = @"SLEEP_REMINDER";

+ (SENNotificationType)typeFromString:(NSString*)type {
    NSString* upper = [type uppercaseString];
    if ([upper isEqualToString:kSENSettingTypeSleepScore]) {
        return SENNotificationTypeSleepScore;
    } else if ([upper isEqualToString:kSENSettingTypeSystem]) {
        return SENNotificationTypeSystem;
    } else if ([upper isEqualToString:kSENSettingTypeSleepReminder]) {
        return SENNotificationTypeSleepReminder;
    } else {
        return SENNotificationTypeUnknown;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)data {
    NSString* name = SENObjectOfClass(data[kSENSettingName], [NSString class]);
    NSString* typeString = SENObjectOfClass(data[kSENSettingType], [NSString class]);
    NSNumber* enabled = SENObjectOfClass(data[kSENSettingEnabled], [NSNumber class]);
    NSDictionary* scheduleDict = SENObjectOfClass(data[kSENSettingSchedule], [NSDictionary class]);
    
    if (!name || !typeString) {
        return nil;
    }
    
    if (self = [super init]) {
        _localizedName = [name copy];
        _type = [SENNotificationSetting typeFromString:typeString];
        _enabled = [enabled boolValue];
        _schedule = _schedule;
        _typeString = typeString;
    }
    
    return self;
}

- (NSDictionary*)dictionaryValue {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:@{kSENSettingName: [self localizedName],
                                     kSENSettingType: [self typeString],
                                     kSENSettingEnabled: @([self isEnabled])}];
    
    if ([self schedule]) {
        NSDictionary* scheduleDict = [[self schedule] dictionaryValue];
        [dict setObject:scheduleDict forKey:kSENSettingSchedule];
    }
    
    return dict;
}

@end
