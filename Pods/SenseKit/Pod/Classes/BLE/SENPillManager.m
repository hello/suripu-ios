
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "SENPillManager.h"
#import "SENPillService.h"
#import "SENPill.h"
#import "SENDateUtils.h"
#import "SENPacketUtils.h"

NSString* const SENDeviceManagerDidWriteCurrentTimeNotification = @"SENDeviceManagerDidWriteCurrentTimeNotification";

NSString* const SENDeviceServiceELLO = @"0000E110-1212-EFDE-1523-785FEABCD123";
NSString* const SENDeviceServiceFFA0 = @"0000FFA0-1212-EFDE-1523-785FEABCD123";
static NSString* const SENDeviceCharacteristicDEED = @"DEED";
static NSString* const SENDeviceCharacteristicD00D = @"D00D";
static NSString* const SENDeviceCharacteristicFEED = @"FEED";
static NSString* const SENDeviceCharacteristicDayDateTime = @"2A0A";
static NSString* const SENDeviceCharacteristicFFAA = @"FFAA";
static NSInteger const BLE_MAX_PACKET_SIZE = 20;

@interface SENPillManager ()
@property (nonatomic, getter=shouldDisconnectPeripheral) BOOL disconnectPeripheral;
@property (nonatomic, strong, readwrite) LGPeripheral* peripheral;
@end

@implementation SENPillManager

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral
{
    if (self = [super init]) {
        _peripheral = peripheral;
    }
    return self;
}

- (void)writeCurrentTimeWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:SENDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:helloService];
        [deed writeValue:SEN_dataForCurrentDate() completion:^(NSError *error) {
            [self readCurrentTimeWithCompletion:completionBlock];
        }];
    } failureBlock:completionBlock];
}

- (void)readCurrentTimeWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:SENDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* read = [self characteristicWithUUIDString:SENDeviceCharacteristicDayDateTime onService:helloService];
        [read setNotifyValue:YES completion:^(NSError *error) {
            if (error) {
                [self invokeCompletionBlock:completionBlock withError:error];
                return;
            }
            LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:helloService];
            [deed writeByte:SENDeviceCommandGetTime completion:^(NSError *error) {
                if (error)
                    [self invokeCompletionBlock:completionBlock withError:error];
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            [self updateDeviceWithDate:SEN_dateForData(data)];
            [self invokeCompletionBlock:completionBlock withError:error];
        }];
    } failureBlock:completionBlock];
}

- (void)fetchDataWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:SENDeviceServiceELLO andPerformBlock:^(LGService* service) {
        LGCharacteristic* feed = [self characteristicWithUUIDString:SENDeviceCharacteristicFEED onService:service];
        __block int expectedPacketCount = 0;
        __block int receivedPacketCount = 0;
        __block NSMutableArray* receivedPackets = [NSMutableArray array];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [feed setNotifyValue:NO completion:^(NSError *error) {
                NSData* compiledPackets = [self formatPacketsInArray:receivedPackets];
                // TODO: reply with 0x0 to F00D for received packets, reply with 0x1 for missing packets
                [self invokeCompletionBlock:completionBlock withError:error];
            }];
        });
        
        [feed setNotifyValue:YES completion:^(NSError *error) {
            if (error) {
                [self invokeCompletionBlock:completionBlock withError:error];
                return;
            }
            LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:service];
            [deed writeByte:SENDeviceCommandSendData completion:^(NSError *error) {
                if (error)
                    [self invokeCompletionBlock:completionBlock withError:error];
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            struct SENPacket packet;
            [data getBytes:&packet length:sizeof(struct SENPacket)];
            if (packet.sequence_number == 0) {
                [receivedPackets insertObject:data atIndex:0];
                expectedPacketCount = packet.header.packet_count;
            } else {
                [receivedPackets addObject:data];
            }
            
            receivedPacketCount++;
        }];
    } failureBlock:completionBlock];
}

- (void)calibrateWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:SENDeviceServiceFFA0 andPerformBlock:^(LGService* service) {
        LGService* helloService = [self serviceWithUUIDString:SENDeviceServiceELLO];
        [helloService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
            LGCharacteristic* ffaa = [self characteristicWithUUIDString:SENDeviceCharacteristicFFAA onService:service];
            [ffaa setNotifyValue:YES completion:^(NSError *error) {
                if (error) {
                    [self invokeCompletionBlock:completionBlock withError:error];
                    return;
                }
                LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:helloService];
                LGCharacteristic* dood = [self characteristicWithUUIDString:SENDeviceCharacteristicD00D onService:helloService];
                [deed writeByte:SENDeviceCommandCalibrate completion:^(NSError *error) {
                    if (error) {
                        [self invokeCompletionBlock:completionBlock withError:error];
                        return;
                    }
                    [dood readValueWithBlock:^(NSData *data, NSError *error) {
                        [self invokeCompletionBlock:completionBlock withError:error];
                        NSLog(@"should get 0x2: %@", data);
                    }];
                }];
            } onUpdate:^(NSData *data, NSError *error) {
//                NSLog(@"Should get some values: %@", data);
            }];
        }];
    } failureBlock:completionBlock];
}

- (void)startDataCollectionWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    
    [self toggleDataCollection:YES withCompletion:completionBlock];
}

- (void)stopDataCollectionWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self toggleDataCollection:NO withCompletion:completionBlock];
}

- (void)disconnectWithCompletion:(SENDeviceErrorBlock)completionBlock
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (![self isConnected]) {
        if (completionBlock)
            completionBlock(nil);
        return;
    }

    [self discoverServiceWithUUIDString:SENDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [self characteristicWithUUIDString:SENDeviceCharacteristicD00D onService:helloService];
        [dood setNotifyValue:YES completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            [deed writeByte:SENDeviceCommandDisconnect completion:^(NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                }
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            if (completionBlock)
                completionBlock(error);
        }];
    } failureBlock:completionBlock];
}

#pragma mark - Private

- (BOOL)isConnected
{
    return self.peripheral.cbPeripheral.state == CBPeripheralStateConnected;
}

/**
 *  Send a message to the peripheral to either start or stop data collection
 *
 *  @param shouldCollectData YES if the peripheral should collect data
 *  @param completionBlock   block invoked when the operation is complete
 */
- (void)toggleDataCollection:(BOOL)shouldCollectData withCompletion:(SENDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:SENDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* deed = [self characteristicWithUUIDString:SENDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [self characteristicWithUUIDString:SENDeviceCharacteristicD00D onService:helloService];
        char byteToSend = shouldCollectData ? SENDeviceCommandStartAccelerometer : SENDeviceCommandStopAccelerometer;
        [deed writeByte:byteToSend completion:^(NSError *error) {
            if (error) {
                [self invokeCompletionBlock:completionBlock withError:error];
                return;
            }
            [dood readValueWithBlock:^(NSData *data, NSError *error) {
                [self invokeCompletionBlock:completionBlock withError:error];
                [self updateDeviceWithDataRecordingState:shouldCollectData];
            }];
        }];
    } failureBlock:completionBlock];
}

/**
 *  Connects to a peripheral and discovers available services, invoking a block with a matching service
 *  upon success.
 *
 *  @param UUIDString   UUID of a particular service on which characteristics are queried
 *  @param successBlock block invoked when connection succeeds
 *  @param failureBlock block invoked when connection fails
 */
- (void)connectAndDiscoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))successBlock failureBlock:(SENDeviceErrorBlock)failureBlock
{
    [self performSelector:@selector(invokeTimeoutBlock:) withObject:failureBlock afterDelay:4];
    if ([self isConnected]) {
        [self discoverServiceWithUUIDString:UUIDString andPerformBlock:successBlock failureBlock:failureBlock];
    } else {
        [self.peripheral connectWithTimeout:3 completion:^(NSError* error) {
            if (error) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                if (failureBlock)
                    failureBlock(error);
                return;
            }
            [self discoverServiceWithUUIDString:UUIDString andPerformBlock:successBlock failureBlock:failureBlock];
        }];
    }
}

- (void)discoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))successBlock failureBlock:(SENDeviceErrorBlock)failureBlock
{
    [self.peripheral discoverServices:nil completion:^(NSArray* services, NSError* error) {
        if (error) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            if (failureBlock)
                failureBlock(error);
            return;
        }
        LGService* service = [self serviceWithUUIDString:UUIDString inArray:services];
        if (service.characteristics) {
            if (successBlock)
                successBlock(service);
        } else {
            [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (error) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                    if (failureBlock)
                        failureBlock(error);
                    return;
                }
                if (successBlock)
                    successBlock(service);
            }];
        }
    }];
}

/**
 *  Invoke an error block with a timeout error
 *
 *  @param block block to run
 */
- (void)invokeTimeoutBlock:(SENDeviceErrorBlock)block
{
    [self.peripheral disconnectWithCompletion:NULL];
    NSError* error = [NSError errorWithDomain:@"co.hello" code:408 userInfo:@{ NSLocalizedDescriptionKey : @"The request to connect timed out." }];
    if (block)
        block(error);
}

/**
 *  Run a block intended to be the end of a set of operations on a peripheral and disconnect
 *
 *  @param completionBlock       the block to run
 *  @param error                 any error raised during operations before the block
 */
- (void)invokeCompletionBlock:(SENDeviceErrorBlock)completionBlock withError:(NSError*)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self disconnectWithCompletion:^(NSError* error) {
        if (completionBlock)
            completionBlock(error);
    }];
}

- (void)updateDeviceWithDataRecordingState:(BOOL)isRecordingData
{
    SENPill* device = [SENPillService deviceWithIdentifier:self.peripheral.UUIDString];
    device.recordingData = isRecordingData;
    [SENPillService updateDevice:device];
}

- (void)updateDeviceWithDate:(NSDate*)date
{
    SENPill* device = [SENPillService deviceWithIdentifier:self.peripheral.UUIDString];
    device.date = date;
    [SENPillService updateDevice:device];
}

#pragma mark Peripheral filtering

- (LGService*)serviceWithUUIDString:(NSString*)UUIDString
{
    return [self serviceWithUUIDString:UUIDString inArray:self.peripheral.services];
}

- (LGService*)serviceWithUUIDString:(NSString*)UUIDString inArray:(NSArray*)services
{
    for (LGService* service in services) {
        if ([[service.UUIDString uppercaseString] isEqualToString:UUIDString]) {
            return service;
        }
    }
    return nil;
}

- (LGCharacteristic*)characteristicWithUUIDString:(NSString*)UUIDString onService:(LGService*)service
{
    for (LGCharacteristic* characteristic in service.characteristics) {
        if ([[characteristic.UUIDString uppercaseString] isEqualToString:UUIDString]) {
            return characteristic;
        }
    }
    return nil;
}

#pragma mark - Data Collection

- (NSData*)formatPacketsInArray:(NSArray*)packets
{
    NSData* headerData = [packets firstObject];
    uint8_t firstPacket[BLE_MAX_PACKET_SIZE];
    [headerData getBytes:&firstPacket length:BLE_MAX_PACKET_SIZE];
    uint8_t expectedPacketCount = firstPacket[1];
    uint8_t packetContainer[expectedPacketCount][BLE_MAX_PACKET_SIZE];

    for (int i = 0; i < packets.count; i++) {
        uint8_t receivedPacket[BLE_MAX_PACKET_SIZE];
        NSData* packetData = packets[i];
        [packetData getBytes:&receivedPacket length:BLE_MAX_PACKET_SIZE];
        uint8_t receivedPacketSize = (sizeof(receivedPacket) / sizeof(receivedPacket[0]));
        uint8_t sequenceNumber = receivedPacket[0];
        memcpy(packetContainer[sequenceNumber], receivedPacket, MIN(BLE_MAX_PACKET_SIZE, receivedPacketSize));
    }
    return [NSData dataWithBytes:packetContainer length:sizeof(packetContainer)];
}

@end
