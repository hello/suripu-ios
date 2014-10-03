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
#import "SENSenseMessage.pb.h"

static CGFloat const kSENSenseDefaultTimeout = 20;
static CGFloat const kSENSenseRescanTimeout = 8;

static NSString* const kSENSenseErrorDomain = @"is.hello.ble";
static NSString* const kSENSenseServiceID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";
static NSString* const kSENSenseCharacteristicInputId = @"BEEB";
static NSString* const kSENSenseCharacteristicResponseId = @"B00B";
static NSInteger const kSENSensePacketSize = 20;
static NSInteger const kSENSenseMessageVersion = 0;

@interface SENSenseManager()

@property (nonatomic, assign, readwrite, getter=isValid) BOOL valid;
@property (nonatomic, strong, readwrite) SENSense* sense;
@property (nonatomic, strong, readwrite) id disconnectNotifyObserver;
@property (nonatomic, strong, readwrite) NSMutableDictionary* disconnectObservers;

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
                                             
                                             // uncomment below to talk to Jimmy :)
//                                             if ([[device name] hasSuffix:@"C9"]) {
//                                                 sense = [[SENSense alloc] initWithPeripheral:device];
//                                                 [senses addObject:sense];
//                                             }
                                             
                                             // uncomment the below code to talk to Pang :)
//                                             if ([[device name] hasSuffix:@"2D"]) {
//                                                 sense = [[SENSense alloc] initWithPeripheral:device];
//                                                 [senses addObject:sense];
//                                             }
                                         }
                                     }
                                     if (completion) completion(senses);
                                 }];
    return YES;
}

+ (void)stopScan {
    if ([[LGCentralManager sharedInstance] isScanning]) {
        [[LGCentralManager sharedInstance] stopScanForPeripherals];
    }
}

+ (BOOL)isScanning {
    return [[LGCentralManager sharedInstance] isScanning];
}

+ (BOOL)isBluetoothOn {
    return [[[LGCentralManager sharedInstance] manager] state] == CBCentralManagerStatePoweredOn;
}

+ (BOOL)isReady {
    return [[LGCentralManager sharedInstance] isCentralReady];
}

- (instancetype)initWithSense:(SENSense*)sense {
    self = [super init];
    if (self) {
        [self setSense:sense];
        [self setValid:YES];
    }
    return self;
}

- (BOOL)isConnected {
    return [[[[self sense] peripheral] cbPeripheral] state] == CBPeripheralStateConnected;
}

- (void)rediscoverToConnectThen:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    [[self class] scanForSenseWithTimeout:kSENSenseRescanTimeout completion:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            BOOL foundAgain = NO;
            if ([senses count] > 0) {
                for (SENSense* sense in senses) {
                    if ([[[strongSelf sense] deviceId] isEqualToString:[sense deviceId]]) {
                        [strongSelf setSense:sense];
                        foundAgain = YES;
                        break;
                    }
                }
                
                if (foundAgain) {
                    [strongSelf setValid:YES];
                    LGPeripheral* peripheral = [[strongSelf sense] peripheral];
                    [peripheral connectWithTimeout:kSENSenseDefaultTimeout completion:completion];
                }
            }
            
            if (!foundAgain && completion) {
                completion ([NSError errorWithDomain:kSENSenseErrorDomain
                                                code:SENSenseManagerErrorCodeInvalidated
                                            userInfo:nil]);
            }
            
        }
    }];
}

/**
 * Connect to Sense then invoke the completion block.  If already connected, completion
 * block will be immediately invoked.
 * param: completion block to invoke when connected, or when there is an error
 */
- (void)connectThen:(void(^)(NSError* error))completion {
    if (!completion) return; // even if we do stuff, what would it be for?
    
    LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        completion ([NSError errorWithDomain:kSENSenseErrorDomain
                                        code:SENSenseManagerErrorCodeNoDeviceSpecified
                                    userInfo:nil]);
        return;
    }
    
    if (![self isConnected]) {
        __weak typeof(self) weakSelf = self;
        
        id postConnectionBlock = ^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && error == nil) {
                [strongSelf listenForUnexpectedDisconnects];
            }
            if (completion) completion (error);
        };
        
        if (![self isValid]) {
            [self rediscoverToConnectThen:postConnectionBlock];
        } else {
            [peripheral connectWithTimeout:kSENSenseDefaultTimeout
                                completion:postConnectionBlock];
        }
    } else {
        completion (nil);
    }
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
    [self characteristicsForServiceId:kSENSenseServiceID
                    characteristicIds:characteristicIds
                           completion:completion];
}

/**
 * Discover characteristics for the specified serviceId.  Upon completion, the
 * characteristics will be returned in a dictionary where key is the id of the
 * characteristic and value is an instance of LGCharacteristic.  If an error
 * is encountered, response will be nil and an NSError is returned instead.
 * @param serviceUUID:       the service UUID to discover
 * @param characteristicIds: a set of characteristicIds that the service broadcasts
 * @param completion:        the block to invoke when done
 */
- (void)characteristicsForServiceId:(NSString*)serviceUUID
                  characteristicIds:(NSSet*)characteristicIds
                         completion:(SENSenseCompletionBlock)completion {
    if (!completion) return; // even if we do stuff, what would it be for?
    if ([characteristicIds count] == 0) {
        completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                             code:SENSenseManagerErrorCodeInvalidArgument
                                         userInfo:nil]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self connectThen:^(NSError *error) {
        if (error != nil) {
            completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                                 code:SENSenseManagerErrorCodeConnectionFailed
                                             userInfo:nil]);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        LGPeripheral* peripheral = [[strongSelf sense] peripheral];
        CBUUID* serviceId = [CBUUID UUIDWithString:serviceUUID];
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

- (void)failWithBlock:(SENSenseFailureBlock)failure andCode:(SENSenseManagerErrorCode)code {
    if (failure) {
        failure ([NSError errorWithDomain:kSENSenseErrorDomain
                                     code:code
                                 userInfo:nil]);
    }
}

#pragma mark - (Private) Sending Data

- (SENSenseMessageBuilder*)messageBuilderWithType:(SENSenseMessageType)type {
    SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
    [builder setType:type];
    [builder setVersion:kSENSenseMessageVersion];
    return builder;
}

/**
 * Format the SENSenseMessage in to HELLO BLE PACKET FORMAT where data is divided
 * in to packets with max size kSENSensePacketSize.  Each packet is stored in
 * order in an array and returned.
 * @param message: a sense message to format
 * @return a sorted array of hello ble packets
 */
- (NSArray*)blePackets:(SENSenseMessage*)message {
    NSInteger initialPayloadSize = kSENSensePacketSize - 2;
    NSInteger additionalPacketSize = kSENSensePacketSize - 1;
    NSData* payload = [message data];
    NSInteger totalPayloadSize = [payload length];
    NSInteger addlPacketSize = MAX(0, totalPayloadSize- initialPayloadSize);
    
    double packets = ceil((double)addlPacketSize / (additionalPacketSize));
    uint8_t numberOfPackets = (uint8_t)(1 + packets);
    
    NSMutableArray* helloBlePackets = [NSMutableArray array];
    NSMutableData* packetData = nil;
    int bytesWritten = 0;
    
    for (uint8_t packetNumber = 0; packetNumber < numberOfPackets; packetNumber++) {
        packetData = [NSMutableData data];
        NSInteger payloadSize = additionalPacketSize; // first byte should always be a sequence number
        
        if (packetNumber == 0) {
            payloadSize = initialPayloadSize;
            uint8_t seq = 0;
            [packetData appendData:[NSData dataWithBytes:&seq
                                                  length:sizeof(seq)]];
            [packetData appendData:[NSData dataWithBytes:&numberOfPackets
                                                  length:sizeof(numberOfPackets)]];
        } else {
            [packetData appendData:[NSData dataWithBytes:&packetNumber
                                                  length:sizeof(packetNumber)]];
        }
        
        uint8_t actualSize = MIN(totalPayloadSize - bytesWritten, payloadSize);
        uint8_t partial[actualSize];
        [payload getBytes:&partial range:NSMakeRange(bytesWritten, actualSize)];
        
        [packetData appendBytes:partial length:actualSize];
        [helloBlePackets addObject:packetData];
        
        bytesWritten += actualSize;
    }
    
    return helloBlePackets;
}

/**
 * Send a message to the initialized Sense through the main service.
 * @param command: the command to send
 * @param success: the success callback when command was sent
 * @param failure: the failure callback called when command failed
 */
- (void)sendMessage:(SENSenseMessage*)message
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    __block LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        return [self failWithBlock:failure andCode:SENSenseManagerErrorCodeNoDeviceSpecified];
    }
    
    __weak typeof(self) weakSelf = self;
    [self characteristics:^(id response, NSError *error) {
        if (error != nil) {
            if (failure) failure (error);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        LGCharacteristic* writer = [response valueForKey:kSENSenseCharacteristicInputId];
        LGCharacteristic* reader = [response valueForKey:kSENSenseCharacteristicResponseId];
        if (writer == nil || reader == nil) {
            return [strongSelf failWithBlock:failure
                                     andCode:SENSenseManagerErrorCodeUnexpectedResponse];
        }
        
        NSArray* packets = [strongSelf blePackets:message];
        
        if ([packets count] > 0) {
            __block NSMutableArray* allPackets = nil;
            __block NSNumber* totalPackets = nil;
            __block typeof(reader) blockReader = reader;
            [reader setNotifyValue:YES completion:^(NSError *error) {
                if (error != nil) {
                    if (failure) failure (error);
                    return;
                }
                [strongSelf sendPackets:packets
                                   from:0
                          throughWriter:writer
                                success:nil
                                failure:^(NSError *error) {
                                    [blockReader setNotifyValue:NO completion:nil];
                                    if (failure) failure (error);
                                }];
            } onUpdate:^(NSData *data, NSError *error) {
                [strongSelf handleResponseUpdate:data
                                           error:error
                                  forMessageType:[message type]
                                      allPackets:&allPackets
                                    totalPackets:&totalPackets
                                         success:^(id response) {
                                             [blockReader setNotifyValue:NO completion:nil];
                                             if (success) success (nil); // don't need to forward response
                                         } failure:^(NSError *error) {
                                             [blockReader setNotifyValue:NO completion:nil];
                                             if (failure) failure (error);
                                         }];
            }];

        } else {
            [strongSelf failWithBlock:failure
                              andCode:SENSenseManagerErrorCodeInvalidCommand];
        }

    }];
}

/**
 * Send all packets, recursively, starting from the specified index in the array.
 * If an error was encountered, recusion will stop and failure block will be called
 * right away.
 *
 * @param packets: the packets to send
 * @param from: index of the packet to send in this iteration
 * @param type: the type of the sense message
 * @param writer: the input characteristic
 * @param reader: the output characteristic
 * @param success: the block to call when all packets have been sent
 * @param failure: the block to call if any error was encountered along the way
 */
- (void)sendPackets:(NSArray*)packets
               from:(NSInteger)index
      throughWriter:(LGCharacteristic*)writer
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    if (![self isConnected]) {
        [self failWithBlock:failure andCode:SENSenseManagerErrorCodeConnectionFailed];
        return;
    }
    
    if (index < [packets count]) {
        NSData* data = packets[index];
        __weak typeof(self) weakSelf = self;
        [writer writeValue:data completion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                if (failure) failure (error);
                return;
            }
            
            if (strongSelf) {
                [strongSelf sendPackets:packets
                                   from:index+1
                          throughWriter:writer
                                success:success
                                failure:failure];
            }

        }];
    } else {
        if (success) success (nil);
    }
}

#pragma mark - (Private) Reading Response

- (SENSenseManagerErrorCode)errorCodeFrom:(ErrorType)senseErrorType {
    SENSenseManagerErrorCode code = SENSenseManagerErrorCodeNone;
    switch (senseErrorType) {
        case ErrorTypeTimeOut:
            code = SENSenseManagerErrorCodeTimeout;
            break;
        case ErrorTypeDeviceAlreadyPaired:
            code = SENSenseManagerErrorCodeDeviceAlreadyPaired;
            break;
        default:
            code = SENSenseManagerErrorCodeUnexpectedResponse;
            break;
    }
    return code;
}

/**
 * Handle response from Sense until it's done sending data back.  Since response
 * will likely be split in to multiple packets, we need to append all data as they
 * arrive until all packets are received.
 *
 * @param data:         the data from 1 update of a response
 * @param error:        any error that may have come from the response
 * @param type:         the type of the message this response is meant for
 * @param allPackets:   the address to the storage holding all data responses
 * @param totalPackets: the address to an object that holds the value of the 
 *                      total packets determined from the first update/packet
 * @param success:      the block to invoke when all updates completed successfully
 * @param failure:      the block to invoke when any update reported an error or
 *                      if the full response is not what was expected for the type
 */
- (void)handleResponseUpdate:(NSData*)data
                       error:(NSError*)error
              forMessageType:(SENSenseMessageType)type
                  allPackets:(NSMutableArray**)allPackets
                totalPackets:(NSNumber**)totalPackets
                     success:(SENSenseSuccessBlock)success
                     failure:(SENSenseFailureBlock)failure {
    
    uint8_t packet[[data length]];
    [data getBytes:&packet length:kSENSensePacketSize];
    if (sizeof(packet) > 2 && error == nil) {
        uint8_t seq = packet[0];
        if (seq == 0) {
            *totalPackets = @(packet[1]);
            *allPackets = [NSMutableArray arrayWithCapacity:[*totalPackets intValue]];
        }
        
        [*allPackets addObject:data];
        
        if ([*totalPackets intValue] == 1 || [*totalPackets intValue] - 1 == seq) {
            NSError* parseError = nil;
            SENSenseMessage* responseMsg = [self messageFromBlePackets:*allPackets error:&parseError];
            if (parseError != nil || [responseMsg type] != type) {
                [self failWithBlock:failure andCode:SENSenseManagerErrorCodeUnexpectedResponse];
            } else {
                if (success) success (responseMsg);
            }
        }
    } else {
        [self failWithBlock:failure andCode:SENSenseManagerErrorCodeUnexpectedResponse];
    }
}

/**
 * Parse the data back in to a SENSenseMessage protobuf object, following the
 * HELLO BLE PACKET FORMAT.
 * @param packets: all hello ble format packets returned from Sense
 * @param error:   a pointer to an error object that will be set if one encountered.
 * @return         a SENSenseMessage
 */
- (SENSenseMessage*)messageFromBlePackets:(NSArray*)packets error:(NSError**)error {
    SENSenseMessage* response = nil;
    SENSenseManagerErrorCode errCode = SENSenseManagerErrorCodeNone;
    NSMutableData* actualPayload = [NSMutableData data];
    
    int index = 0;
    for (NSData* packetData in packets) {
        int offset = index == 0 ? 2 : 1;
        long packetLength = [packetData length] - offset;
        uint8_t payloadPacket[packetLength];
        long length = sizeof(payloadPacket);
        [packetData getBytes:&payloadPacket range:NSMakeRange(offset, packetLength)];
        [actualPayload appendBytes:payloadPacket length:length];
        index++;
    }
    
    @try {
        response = [SENSenseMessage parseFromData:actualPayload];
        if ([response hasError]) {
            errCode = [self errorCodeFrom:[response error]];
        }
    } @catch (NSException *exception) {
        errCode = SENSenseManagerErrorCodeUnexpectedResponse;
    }
    
    if (errCode != SENSenseManagerErrorCodeNone && error != NULL) {
        *error = [NSError errorWithDomain:kSENSenseErrorDomain
                                     code:SENSenseManagerErrorCodeUnexpectedResponse
                                 userInfo:nil];
    }
    return response;
}

#pragma mark - Pairing

/**
 * Pairing with Sense requires a simple subscription to the output characteristic,
 * which will force authorization from the device wanting to pair
 *
 * @param success: the block to invoke when pairing completed successfully
 * @param failure: the block to invoke when an error was encountered
 */
- (void)pair:(SENSenseSuccessBlock)success
     failure:(SENSenseFailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    [self characteristicsFor:[NSSet setWithObject:kSENSenseCharacteristicResponseId]
                  completion:^(id response, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      if (!strongSelf) return;
                      
                      NSDictionary* readWrite = response;
                      __weak LGCharacteristic* reader = [readWrite valueForKey:kSENSenseCharacteristicResponseId];
                      
                      if (reader == nil) {
                          return [strongSelf failWithBlock:failure
                                                   andCode:SENSenseManagerErrorCodeUnexpectedResponse];
                      }
                      
                      [reader setNotifyValue:YES completion:^(NSError *error) {
                          __strong typeof(reader) strongReader = reader;
                          if (!strongReader) return;
                          
                          [strongReader setNotifyValue:NO completion:nil];
                          
                          if (error != nil) {
                              if (failure) failure (error);
                          } else {
                              if (success) success (nil);
                          }

                      }];
                  }];
}

- (void)enablePairingMode:(BOOL)enable
                  success:(SENSenseSuccessBlock)success
                  failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type
        = enable
        ? SENSenseMessageTypeSwitchToPairingMode
        : SENSenseMessageTypeSwitchToNormalMode;

    [self sendMessage:[[self messageBuilderWithType:type] build]
              success:success failure:failure];
}

- (void)removeOtherPairedDevices:(SENSenseSuccessBlock)success
                         failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type = SENSenseMessageTypeEreasePairedPhone;
    [self sendMessage:[[self messageBuilderWithType:type] build]
              success:success failure:failure];
}

- (void)linkAccount:(NSString*)accountAccessToken
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type = SENSenseMessageTypePairSense;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setAccountId:accountAccessToken];
    [self sendMessage:[builder build] success:success failure:failure];
}

- (void)pairWithPill:(NSString*)accountAccessToken
             success:(SENSenseSuccessBlock)success
             failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type = SENSenseMessageTypePairPill;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setAccountId:accountAccessToken];
    [self sendMessage:[builder build] success:success failure:failure];
}

- (void)unpairPill:(NSString*)pillId
           success:(SENSenseSuccessBlock)success
           failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type = SENSenseMessageTypeUnpairPill;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setDeviceId:pillId];
    [self sendMessage:[builder build] success:success failure:failure];
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

#pragma mark - Signal Strength / RSSI

- (void)currentRSSI:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    [self connectThen:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            if (failure) failure (error);
        } else if (strongSelf) {
            [strongSelf readPeripheralRSSI:success failure:failure];
        }
    }];
}

- (void)readPeripheralRSSI:(SENSenseSuccessBlock)success
                   failure:(SENSenseFailureBlock)failure {
    [[[self sense] peripheral] readRSSIValueCompletion:^(NSNumber *RSSI, NSError *error) {
        if (error) {
            if (failure) failure (error);
        } else if (success) {
            success (RSSI);
        }
    }];
}

#pragma mark - Connections

- (void)disconnectFromSense {
    if  ([self isConnected]) {
        __weak typeof(self) weakSelf = self;
        [[[self sense] peripheral] disconnectWithCompletion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) [strongSelf setValid:NO];
        }];
    }
}

- (void)listenForUnexpectedDisconnects {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    if ([self disconnectNotifyObserver] != nil) {
        [center removeObserver:[self disconnectNotifyObserver]];
    }
    
    __weak typeof(self) weakSelf = self;
    self.disconnectNotifyObserver =
        [center addObserverForName:kLGPeripheralDidDisconnect
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *note) {
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            if (!strongSelf) return;
                            
                            // if peripheral is disconnected, it is removed from
                            // scannedPeripherals in LGCentralManager, which causes
                            // the reference to SENSense's peripheral to not be
                            // recognized.  This is actually not a logic problem
                            // from the library, but also the behavior in CoreBluetooth
                            [strongSelf setValid:NO];
                            
                            NSError* error = [[note userInfo] valueForKey:@"error"];
                            for (NSString* observerId in [strongSelf disconnectObservers]) {
                                SENSenseFailureBlock block = [[strongSelf disconnectObservers] valueForKey:observerId];
                                block (error);
                            }
                        }];
}

- (NSString*)observeUnexpectedDisconnect:(SENSenseFailureBlock)block {
    if ([self disconnectObservers] == nil) {
        [self setDisconnectObservers:[NSMutableDictionary dictionary]];
    }
    NSString* observerId = [[NSUUID UUID] UUIDString];
    [[self disconnectObservers] setValue:[block copy] forKey:observerId];
    return observerId;
}

- (void)removeUnexpectedDisconnectObserver:(NSString*)observerId {
    if (observerId != nil) {
        [[self disconnectObservers] removeObjectForKey:observerId];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    if ([self isConnected]) {
        [[[self sense] peripheral] disconnectWithCompletion:nil];
    }
    
    if ([self disconnectNotifyObserver]) {
        [[NSNotificationCenter defaultCenter] removeObserver:[self disconnectNotifyObserver]];
    }
}

@end
