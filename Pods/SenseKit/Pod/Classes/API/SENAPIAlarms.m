
#import <AFNetworking/AFURLResponseSerialization.h>
#import "SENAPIAlarms.h"
#import "Model.h"

@implementation SENAPIAlarms

static NSString* const kSENAPIAlarmsResource = @"v2/alarms";
static NSString* const kSENAPIAlarmsUpdateClientTimeFormat = @"/%.0f";
static NSString* const kSENAPIAlarmsSoundsPath = @"sounds";

static SENAPIDataBlock SENAPIAlarmDataBlock(SENAPIDataBlock completion) {
    return ^(NSArray* data, NSError* error) {
        SENAlarmCollection* collection = nil;
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            collection = [[SENAlarmCollection alloc] initWithDictionary:data];
        }

        if (completion) {
            completion(collection, error);
        }
    };
}

+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion {
    [SENAPIClient GET:kSENAPIAlarmsResource
           parameters:nil
           completion:SENAPIAlarmDataBlock(completion)];
}

+ (void)updateAlarms:(SENAlarmCollection*)alarms completion:(nullable SENAPIDataBlock)completion {
    NSTimeInterval clientTimeUTC = [SENDateMillisecondsSince1970([NSDate date]) doubleValue];
    NSDictionary* serializedAlarms = [alarms dictionaryValue];
    NSString* path = [kSENAPIAlarmsResource stringByAppendingFormat:kSENAPIAlarmsUpdateClientTimeFormat, clientTimeUTC];
    [SENAPIClient POST:path
            parameters:serializedAlarms
            completion:SENAPIAlarmDataBlock(completion)];
}

+ (void)availableSoundsWithCompletion:(SENAPIDataBlock)completion {
    NSString* soundsPath = [kSENAPIAlarmsResource stringByAppendingPathComponent:kSENAPIAlarmsSoundsPath];
    [SENAPIClient GET:soundsPath parameters:nil completion:^(id data, NSError *error) {
        if (error || ![data isKindOfClass:[NSArray class]]) {
            completion(nil, error);
            return;
        }
        NSMutableArray* sounds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary* soundData in data) {
            [sounds addObject:[[SENSound alloc] initWithDictionary:soundData]];
        }
        completion(sounds, nil);
    }];
}

@end
