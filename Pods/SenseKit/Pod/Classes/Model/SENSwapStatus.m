//
//  SENUpgradeStatus.m
//  Pods
//
//  Created by Jimmy Lu on 8/25/16.
//
//

#import "SENSwapStatus.h"
#import "Model.h"

static NSString* const kSENSwapStatusProp = @"status";
static NSString* const kSENSwapStatusEnumOk = @"OK";
static NSString* const kSENSwapStatusEnumMultiple = @"ACCOUNT_PAIRED_TO_MULTIPLE_SENSE";
static NSString* const kSENSwapStatusEnumAnother = @"NEW_SENSE_PAIRED_TO_DIFFERENT_ACCOUNT";

@implementation SENSwapStatus

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self && data) {
        NSString* status = SENObjectOfClass(data[kSENSwapStatusProp], [NSString class]);
        _response = [self responseValueFromString:status];
    }
    return self;
}


- (SENSwapResponse)responseValueFromString:(NSString*)response {
    SENSwapResponse value = SENSwapResponseOk;
    if ([[response uppercaseString] isEqualToString:kSENSwapStatusEnumMultiple]) {
        value = SENSwapResponseTooManyDevices;
    } else if ([[response uppercaseString] isEqualToString:kSENSwapStatusEnumAnother]) {
        value = SENSwapResponsePairedToAnother;
    }
    return value;
}

@end
