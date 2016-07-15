//
//  SENPeripheralManager.m
//  Pods
//
//  Created by Jimmy Lu on 6/30/16.
//
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "SENPeripheralManager.h"

static NSUInteger const SENPeripheralManagerBLECheckRetries = 10;
static CGFloat const SENPeripheralManagerBLECheckRetryDelay = 0.2f;

@interface SENPeripheralManager()

@property (nonatomic, weak) CBCentralManager* tempCentral;

@end

@implementation SENPeripheralManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#pragma mark - Central availability

+ (void)whenCentralManager:(CBCentralManager*)centralManager isReady:(SENPeripheralReadyCallback)completion {
    [self whenCentralManager:centralManager withAttempt:1 isReady:completion];
}

+ (void)whenReady:(SENPeripheralReadyCallback)completion {
    CBCentralManager* centralManager = [[LGCentralManager sharedInstance] manager];
    [self whenCentralManager:centralManager withAttempt:1 isReady:completion];
}

+ (void)whenCentralManager:(CBCentralManager*)centralManager
               withAttempt:(NSInteger)attempt
                   isReady:(SENPeripheralReadyCallback)completion {
    BOOL ready = [centralManager state] == CBCentralManagerStatePoweredOn;
    if (attempt > SENPeripheralManagerBLECheckRetries || ready) {
        return completion (ready);
    } else {
        __block NSInteger nextAttempt = attempt + 1;
        __weak typeof(self) weakSelf = self;
        int64_t delay =  (int64_t)(SENPeripheralManagerBLECheckRetryDelay * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf whenCentralManager:centralManager withAttempt:nextAttempt isReady:completion];
        });
    }
}

+ (BOOL)isReady {
    return [[LGCentralManager sharedInstance] isCentralReady];
}

#pragma mark - BLE Scan

+ (BOOL)canScan {
    CBCentralManagerState state = [[[LGCentralManager sharedInstance] manager] state];
    return state != CBCentralManagerStateUnauthorized
        && state != CBCentralManagerStateUnsupported;
}

+ (BOOL)isScanning {
    return [[LGCentralManager sharedInstance] isScanning];
}

+ (void)stopScan {
    if ([[LGCentralManager sharedInstance] isScanning]) {
        [[LGCentralManager sharedInstance] stopScanForPeripherals];
        DDLogVerbose(@"scan stopped");
    }
}

#pragma mark - Characteristics

- (void)characteristicsWithIds:(NSSet*)characteristicIds
               insideServiceId:(NSString*)serviceUUID
                 forPeripheral:(LGPeripheral*)peripheral
                    completion:(SENPeripheralResponseCallback)completion {
    
    NSDictionary* characteristics = [self cachedCharacteristicsWithIds:characteristicIds
                                                        fromPeripheral:peripheral
                                                          forServiceId:serviceUUID];
    if ([characteristics count] > 0) {
        return completion (characteristics, nil);
    }
    
    __weak typeof(self) weakSelf = self;
    CBUUID* serviceId = [CBUUID UUIDWithString:serviceUUID];
    [peripheral discoverServices:@[serviceId] completion:^(NSArray *services, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            completion (nil, error);
        } else {
            DDLogVerbose(@"discovering characteristics for service");
            LGService* lgService = [services firstObject];
            [lgService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (error != nil) {
                    completion (nil, error);
                    return;
                }
                completion ([strongSelf extractCharacteristicsWithIds:characteristicIds
                                                                 from:characteristics], nil);
            }];
        }
        
    }];
}

/**
 * @discussion
 * If peripheral contains cached service and characteristics, then use it rather
 * than discovering them through BLE.  If cache does exist and you still try and
 * discover them, CoreBluetooth will not make a callback.
 *
 * @param characteristicIds: a set of characteristicIds that the service broadcasts
 * @param peripheral:        Sense
 * @param serviceUUID:       the service UUID to discover
 *
 * @return dictionary of characteristics by ids, if any
 */
- (NSDictionary*)cachedCharacteristicsWithIds:(NSSet*)characteristicIds
                               fromPeripheral:(LGPeripheral*)peripheral
                                 forServiceId:(NSString*)serviceUUID {
    
    NSDictionary* matching = nil;
    for (LGService* service in [peripheral services]) {
        if ([[[service UUIDString] uppercaseString] isEqualToString:serviceUUID]) {
            matching = [self extractCharacteristicsWithIds:characteristicIds
                                                      from:[service characteristics]];
            DDLogVerbose(@"using cached Sense service and characteristics");
            break;
        }
    }
    return matching;
}

/**
 * @discussion
 * Convenience method to construct a dictionary of of characteristic objects matching
 * the characteristic ids specified, if any
 *
 * @param characteristicIds: UUIDs of characteristics to extract
 * @param allCharacteristics: an array of characteristic objects
 * @return a dictionary of characteristic UUIDs / characteristic object pairs
 */
- (NSDictionary*)extractCharacteristicsWithIds:(NSSet*)characteristicIds
                                          from:(NSArray*)allCharacteristics {
    
    NSMutableDictionary* characteristics = [NSMutableDictionary dictionary];
    NSString* uuid = nil;
    for (LGCharacteristic* characteristic in allCharacteristics) {
        uuid = [[characteristic UUIDString] uppercaseString];
        if ([characteristicIds containsObject:uuid]) {
            [characteristics setValue:characteristic forKey:uuid];
        }
    }
    return characteristics;
}

@end
