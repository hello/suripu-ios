//
//  SENDevicePairingInfo.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import "SENDevicePairingInfo.h"
#import "Model.h"

static NSString* const SENDevicePairingInfoDictPropSenseId = @"sense_id";
static NSString* const SENDevicePairingInfoDictPropAccounts = @"paired_accounts";

@interface SENDevicePairingInfo()

@property (nonatomic, copy)   NSString* senseId;
@property (nonatomic, strong) NSNumber* pairedAccounts;

@end

@implementation SENDevicePairingInfo

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _senseId = SENObjectOfClass(dict[SENDevicePairingInfoDictPropSenseId],
                                    [NSString class]);
        _pairedAccounts = SENObjectOfClass(dict[SENDevicePairingInfoDictPropAccounts],
                                           [NSNumber class]);
    }
    return self;
}

@end
