//
//  SENDevices.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//
#import "SENPairedDevices.h"
#import "Model.h"

static NSString* const HEMDevicesDictPropSenses = @"senses";
static NSString* const HEMDevicesDictPropPills = @"pills";

@interface SENPairedDevices()

@property (nonatomic, strong) NSArray<SENSenseMetadata*> *senses;
@property (nonatomic, strong) NSArray<SENPillMetadata*> *pills;

@end

@implementation SENPairedDevices

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _senses = [self senseArrayFromValue:dict[HEMDevicesDictPropSenses]];
        _pills = [self pillArrayFromValue:dict[HEMDevicesDictPropPills]];
    }
    return self;
}

- (NSArray<SENSenseMetadata *>*)senseArrayFromValue:(NSArray*)value {
    NSMutableArray<SENSenseMetadata*>* senses = [NSMutableArray new];
    
    for (id object in value) {
        NSDictionary* dict = SENObjectOfClass(object, [NSDictionary class]);
        [senses addObject:[[SENSenseMetadata alloc] initWithDictionary:dict]];
    }
                           
    return senses;
}

- (NSArray<SENPillMetadata *>*)pillArrayFromValue:(NSArray*)value {
    NSMutableArray<SENPillMetadata*>* pills = [NSMutableArray new];
    
    for (id object in value) {
        NSDictionary* dict = SENObjectOfClass(object, [NSDictionary class]);
        [pills addObject:[[SENPillMetadata alloc] initWithDictionary:dict]];
    }
    
    return pills;
}

- (SENSenseMetadata*)senseMetadata {
    return [[self senses] firstObject];
}

- (SENPillMetadata*)pillMetadata {
    return [[self pills] firstObject];
}

- (BOOL)hasPairedSense {
    return [[[self senseMetadata] uniqueId] length] > 0;
}

- (BOOL)hasPairedPill {
    return [[[self pillMetadata] uniqueId] length] > 0;
}

- (void)removePairedPill {
    [self setPills:@[]];
}

- (void)removePairedSense {
    [self setSenses:@[]];
}

@end
