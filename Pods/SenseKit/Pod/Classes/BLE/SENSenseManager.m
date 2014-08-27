//
//  SENSenseManager.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "LGCentralManager.h"
#import "LGPeripheral.h"

#import "SENSenseManager.h"
#import "SENSense+Protected.h"
#import "SENPacketUtils.h"

static CGFloat const kSENSenseDefaultTimeout = 5;

static NSString* const kSENSenseErrorDomain = @"is.hello.ble";
static NSString* const kSENSenseServiceID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";
static NSString* const kSENSenseCharacteristicInputId = @"BEEB";
static NSString* const kSENSenseCharacteristicResponseId = @"B00B";

@interface SENSenseManager()

@property (nonatomic, strong, readwrite) SENSense* sense;

@end

@implementation SENSenseManager

+ (BOOL)scanForSense:(void(^)(NSArray* senses))completion {
    return [self scanForSenseWithTimeout:kSENSenseDefaultTimeout
                              completion:completion];
}

+ (BOOL)scanForSenseWithTimeout:(NSTimeInterval)timeout
                     completion:(void(^)(NSArray* senses))completion {
    LGCentralManager* btManager = [LGCentralManager sharedInstance];
    if (![btManager isCentralReady]) return NO;
    
    CBUUID* serviceId = [CBUUID UUIDWithString:kSENSenseServiceID];
    [btManager scanForPeripheralsByInterval:timeout
                                   services:@[serviceId]
                                    options:nil
                                 completion:^(NSArray* peripherals) {
                                     NSMutableArray* senses = nil;
                                     NSInteger count = [peripherals count];
                                     SENSense* sense = nil;
                                     if (count > 0) {
                                         senses = [NSMutableArray arrayWithCapacity:count];
                                         for (LGPeripheral* device in peripherals) {
                                             sense = [[SENSense alloc] initWithPeripheral:device];
                                             [senses addObject:sense];
                                         }
                                     }
                                     if (completion) completion(senses);
                                 }];
    return YES;
}

+ (void)stopScan {
    [[LGCentralManager sharedInstance] stopScanForPeripherals];
}

- (instancetype)initWithSense:(SENSense*)sense {
    self = [super init];
    if (self) {
        [self setSense:sense];
    }
    return self;
}

/**
 * Obtain LGCharacteristic objects that match the characteristicIds specified.  On completion, the
 * response in the completion block will be a NSDictionary with the characteristicId as the key and
 * the value being the LGCharacteristic object.
 *
 * To obtain such characteristics, this method will connect to the initialized device, scan for the
 * device service and then retrieve the matching characteristics.
 *
 * @param characteristicIds: a set of characteristicIds to retrieve
 * @param completion: the block to call upon completion
 */
- (void)characteristicsFor:(NSSet*)characteristicIds completion:(SENSenseCompletionBlock)completion {
    if (!completion) return; // even if we do stuff, what would it be for?
    if ([characteristicIds count] == 0) {
        completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                             code:SENSenseManagerErrorCodeNoInvalidArgument
                                         userInfo:nil]);
        return;
    }
    
    LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                             code:SENSenseManagerErrorCodeNoDeviceSpecified
                                         userInfo:nil]);
        return;
    }
    
    [peripheral connectWithTimeout:kSENSenseDefaultTimeout completion:^(NSError *error) {
        if (error != nil) {
            completion (nil, error);
        }
        CBUUID* serviceId = [CBUUID UUIDWithString:kSENSenseServiceID];
        [peripheral discoverServices:@[serviceId] completion:^(NSArray *services, NSError *error) {
            if (error != nil || [services count] != 1) {
                completion (nil, error?error:[NSError errorWithDomain:kSENSenseErrorDomain
                                                                 code:SENSenseManagerErrorCodeUnexpectedResponse
                                                             userInfo:nil]);
                return;
            }
            LGService* lgService = [services firstObject];
            [lgService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (error != nil) {
                    completion (nil, error);
                    return;
                }
                NSMutableDictionary* abilities = [NSMutableDictionary dictionaryWithCapacity:2];
                NSString* uuid = nil;
                for (LGCharacteristic* characteristic in characteristics) {
                    uuid = [[characteristic UUIDString] uppercaseString];
                    if ([characteristicIds containsObject:uuid]) {
                        [abilities setValue:characteristic forKey:uuid];
                    }
                }
                completion (abilities, nil);
            }];
        }];
    }];
}

- (void)characteristics:(SENSenseCompletionBlock)completion {
    [self characteristicsFor:[NSMutableSet setWithObjects:kSENSenseCharacteristicInputId,
                                                          kSENSenseCharacteristicResponseId,
                                                          nil]
                  completion:completion];
}

/**
 * Send a command to the initialized Sense through the main service.
 * @param command: the command to send
 * @param success: the success callback when command was sent
 * @param failure: the failure callback called when command failed
 */
- (void)sendCommand:(int8_t)command
            success:(SENSenseSuccessBlock)sucess
            failure:(SENSenseFailureBlock)failure {
    
    __block LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        if (failure) {
            failure ([NSError errorWithDomain:kSENSenseErrorDomain
                                         code:SENSenseManagerErrorCodeNoDeviceSpecified
                                     userInfo:nil]);
        }
        return;
    }
    
    [self characteristics:^(id response, NSError *error) {
        if (error) {
            if (failure) failure (error);
            return;
        }

        NSDictionary* readWrite = response;
        LGCharacteristic* writer = [readWrite valueForKey:kSENSenseCharacteristicInputId];
        LGCharacteristic* reader = [readWrite valueForKey:kSENSenseCharacteristicResponseId];
        // according to the Pang, every command will send a response back with the same
        // packet that was sent to the device as confirmation
        if (writer == nil || reader == nil) {
            if (failure) failure ([NSError errorWithDomain:kSENSenseErrorDomain
                                                      code:SENSenseManagerErrorCodeUnexpectedResponse
                                                  userInfo:nil]);
            return;
        }
        
        [writer writeByte:command completion:^(NSError *error) {
            if (error) {
                if (failure) failure (error);
                return;
            }
        }];
        [reader readValueWithBlock:^(NSData *data, NSError *error) {
            if (error != nil) {
                if (failure) failure (error);
                return;
            }

            struct SENPacket packet;
            [data getBytes:&packet length:sizeof(struct SENPacket)];
            // TODO (jimmy): verify packet?
            if (sucess) sucess( nil );
        }];
    }];
}

#pragma mark - Paring

- (void)enablePairingMode:(BOOL)enable
                  success:(SENSenseSuccessBlock)success
                  failure:(SENSenseFailureBlock)failure {
    int8_t command = enable ? SENSenseCommandEnterPairMode : SENSenseCommandExitPairMode;
    [self sendCommand:command success:success failure:failure];
}

- (void)removePairedUser:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

#pragma mark - Time

- (void)setTime:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getTime:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

#pragma mark - Wifi

- (void)setWifiEndPoint:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getWifiEndPoint:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)scanForWifi:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)stopWifiScan:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

#pragma mark - Alarms

- (void)setAlarms:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getAlarms:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

@end
