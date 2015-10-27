//
//  SENDeviceMetadata.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import "SENDeviceMetadata.h"
#import "Model.h"

static NSString* const SENDeviceMetadataDictPropId = @"id";
static NSString* const SENDeviceMetadataDictPropFW = @"firmware_version";
static NSString* const SENDeviceMetadataDictPropLastUpdated = @"last_updated";

@interface SENDeviceMetadata()

@property (nonatomic, copy) NSString* uniqueId;
@property (nonatomic, copy) NSString* firmwareVersion;
@property (nonatomic, strong) NSDate* lastSeenDate;

@end

@implementation SENDeviceMetadata

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _uniqueId = [SENObjectOfClass(dict[SENDeviceMetadataDictPropId],
                                      [NSString class]) copy];
        _firmwareVersion = [SENObjectOfClass(dict[SENDeviceMetadataDictPropFW],
                                             [NSString class]) copy];
        _lastSeenDate = SENDateFromNumber(dict[SENDeviceMetadataDictPropLastUpdated]);
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{SENDeviceMetadataDictPropId : [self uniqueId] ?: @"",
             SENDeviceMetadataDictPropFW : [self firmwareVersion] ?: @"",
             SENDeviceMetadataDictPropLastUpdated : [self lastSeenDate] ?: @0};
}

@end
