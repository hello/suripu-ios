//
//  SENSleepPillManager.m
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//

@import iOSDFULibrary;

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "SENSleepPillManager.h"
#import "SENSleepPill.h"

NSString* const SENSleepPillManagerErrorDomain = @"is.hello.ble.pill";

static NSString* const SENSleepPillDfuServiceUUID = @"00001530-1212-EFDE-1523-785FEABCD123";
static NSString* const SENSleepPillServiceUUID = @"0000e110-1212-efde-1523-785feabcd123";
static NSString* const SENSleepPillCharacteristicUUID = @"DEED";

static CGFloat const SENSleepPillDefaultScanTimeout = 8.0f;
static CGFloat const SENSleepPillConnectionTimeout = 10.0f;
static int8_t const SENSleepPillDfuPayload = 8;
static CGFloat const SENSleepPillDfuDelay = 5.0f;

@interface SENSleepPillManager() <DFUProgressDelegate, DFUServiceDelegate>

@property (nonatomic, strong) SENSleepPill* sleepPill;
@property (nonatomic, strong) DFUServiceController* dfuController;
@property (nonatomic, copy) SENSleepPillManagerProgressBlock progressBlock;
@property (nonatomic, copy) SENSleepPillManagerDFUBlock dfuCompletionBlock;
@property (nonatomic, copy) SENSleepPillResponseHandler enableDfuBlock;
@property (nonatomic, assign) SENSleepPillDfuState currentDfuState;
@property (nonatomic, assign) BOOL rediscoveryRequired;

@end

@implementation SENSleepPillManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

+ (NSError*)errorWithCode:(SENSleepPillErrorCode)code reason:(NSString*)reason {
    NSDictionary* info = nil;
    if (reason) {
        info = @{NSLocalizedDescriptionKey : reason};
    }
    return [NSError errorWithDomain:SENSleepPillManagerErrorDomain
                               code:code
                           userInfo:info];
}

+ (void)scanForSleepPills:(SENSleepPillManagerScanBlock)completion {
    if (![self canScan]) {
        NSError* error = [self errorWithCode:SENSleepPillErrorCodeNotSupported reason:nil];
        return completion (nil, error);
    }
    
    [self whenReady:^(BOOL ready) {
        if (!ready) {
            NSError* error = [self errorWithCode:SENSleepPillErrorCodeNotSupported reason:nil];
            return completion (nil, error);
        }
        
        void(^scanDone)(NSArray* peripherals) = ^(NSArray* peripherals) {
            NSMutableArray* sleepPills = nil;
            NSInteger count = [peripherals count];
            if (count > 0) {
                sleepPills = [NSMutableArray arrayWithCapacity:count];
                for (LGPeripheral* peripheral in peripherals) {
                    [sleepPills addObject:[[SENSleepPill alloc] initWithPeripheral:peripheral]];
                }
            }
            completion (sleepPills, nil);
        };
        
        CBUUID* serviceId = [CBUUID UUIDWithString:SENSleepPillServiceUUID];
        CBUUID* dfuServiceId = [CBUUID UUIDWithString:SENSleepPillDfuServiceUUID];
        LGCentralManager* central = [LGCentralManager sharedInstance];
        [central scanForPeripheralsByInterval:SENSleepPillDefaultScanTimeout
                                     services:@[serviceId, dfuServiceId]
                                      options:nil
                                   completion:scanDone];
    }];
}

- (instancetype)initWithSleepPill:(SENSleepPill*)sleepPill {
    if (!sleepPill) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _sleepPill = sleepPill;
    }
    return self;
}

- (void)rediscoverThen:(SENSleepPillResponseHandler)completion {
    __weak typeof(self) weakSelf = self;
    
    void(^fail)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        SENSleepPillErrorCode code = SENSleepPillErrorCodeRediscoveryFailed;
        NSString* reason = [error localizedDescription] ?: @"could not rediscover pill";
        completion ([[strongSelf class] errorWithCode:code reason:reason]);
    };
    
    DDLogVerbose(@"rediscovering pill peripheral");
    [[self class] scanForSleepPills:^(NSArray<SENSleepPill *> * pills, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error || [pills count] == 0) {
            fail ( error );
        } else {
            BOOL rediscovered = NO;
            for (SENSleepPill* pill in pills) {
                if ([[pill name] isEqualToString:[[strongSelf sleepPill] name]]) {
                    [strongSelf setSleepPill:pill];
                    rediscovered = YES;
                    break;
                }
            }
            
            if (!rediscovered) {
                fail ( nil );
            } else {
                [strongSelf setRediscoveryRequired:NO];
                completion (nil);
            }
        }
    }];
}

#pragma mark - Connection

- (void)listenForUnexpectedDisconnects {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kLGPeripheralDidDisconnect object:nil];
    [center addObserver:self
               selector:@selector(unexpectedlyDisconnected:)
                   name:kLGPeripheralDidDisconnect
                 object:nil];
}

- (void)unexpectedlyDisconnected:(NSNotification*)note {
    if ([self enableDfuBlock]) { // if enabling DFU, pill may disconnect
        [self enableDfuBlock] (nil);
        [self setEnableDfuBlock:nil];
    } else if ([self dfuCompletionBlock]) {
        SENSleepPillErrorCode code = SENSleepPillErrorCodeUnexpectedDisconnect;
        NSString* reason = @"unexpectedly disconnected from the pill";
        [self endDfuWithError:[[self class] errorWithCode:code reason:reason]];
        [self setRediscoveryRequired:YES];
    }
}

- (BOOL)isConnected {
    LGPeripheral* peripheral = [[self sleepPill] peripheral];
    return [[peripheral cbPeripheral] state] == CBPeripheralStateConnected;
}

- (void)disconnect:(SENSleepPillResponseHandler)completion {
    LGPeripheral* peripheral = [[self sleepPill] peripheral];
    return [peripheral disconnectWithCompletion:completion];
}

- (void)connect:(SENSleepPillResponseHandler)completion {
    if (![self sleepPill]) {
        NSString* reason = @"attempted to connect to a non-existent pill";
        SENSleepPillErrorCode code = SENSleepPillErrorCodePillNotfound;
        return completion ([[self class] errorWithCode:code reason:reason]);
    }
    
    if ([self isConnected]) {
        return completion (nil);
    } else {
        __weak typeof(self) weakSelf = self;
        void(^connect)(void) = ^(void) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [[[strongSelf sleepPill] peripheral] connectWithTimeout:SENSleepPillConnectionTimeout completion:^(NSError *error) {
                NSError* localError = nil;
                if (error) {
                    NSString* reason = [error localizedDescription];
                    SENSleepPillErrorCode code = SENSleepPillErrorCodeConnectionFailed;
                    localError = [[strongSelf class] errorWithCode:code reason:reason];
                }
                completion (localError);
            }];
        };
        
        if ([self rediscoveryRequired]) {
            [self rediscoverThen:^(NSError * _Nullable error) {
                connect();
            }];
        } else {
            connect();
        }
    }
}

#pragma mark - DFU

- (BOOL)isInDfuMode {
    LGPeripheral* peripheral = [[self sleepPill] peripheral];
    NSDictionary* advertisingData = [peripheral advertisingData];
    NSArray* serviceIds = [advertisingData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    CBUUID* dfuServiceId = [CBUUID UUIDWithString:SENSleepPillDfuServiceUUID];
    return [serviceIds containsObject:dfuServiceId];
}

- (void)enableDfuMode:(BOOL)enable completion:(SENSleepPillResponseHandler)completion {
    if ([self isInDfuMode]) {
        return completion (nil);
    }
    
    [self setEnableDfuBlock:completion];
    [self listenForUnexpectedDisconnects];
    
    __weak typeof(self) weakSelf = self;
    [self connect:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSSet* characteristicIds = [NSSet setWithObject:SENSleepPillCharacteristicUUID];
        [strongSelf characteristicsWithIds:characteristicIds
                           insideServiceId:SENSleepPillServiceUUID
                             forPeripheral:[[strongSelf sleepPill] peripheral]
                                completion:^(NSDictionary* characteristics, NSError * error) {
                                    if (!error) {
                                        LGCharacteristic* write = characteristics[SENSleepPillCharacteristicUUID];
                                        if (write) {
                                            [write writeByte:SENSleepPillDfuPayload completion:^(NSError *error) {
                                                [strongSelf enableDfuBlock] (error);
                                                [strongSelf setEnableDfuBlock:nil];
                                            }];
                                        } else {
                                            SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuMissingCharacteristic;
                                            NSString* reason = @"characteristic not found";
                                            NSError* error = [[strongSelf class] errorWithCode:code reason:reason];
                                            [strongSelf enableDfuBlock] (error);
                                            [strongSelf setEnableDfuBlock:nil];
                                        }
                                    } else {
                                        [strongSelf enableDfuBlock] (error);
                                        [strongSelf setEnableDfuBlock:nil];
                                    }
                                }];
    }];
}

- (void)performDFUWithURL:(NSString*)url
                 progress:(SENSleepPillManagerProgressBlock)progress
               completion:(SENSleepPillManagerDFUBlock)completion {
    
    if ([self dfuCompletionBlock]) {
        SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuInProgress;
        completion ([[self class] errorWithCode:code reason:@"a dfu is in progress"]);
        return;
    }
    
    [self setProgressBlock:progress];
    [self setDfuCompletionBlock:completion];
    [self listenForUnexpectedDisconnects];
    
    if (![self isInDfuMode]) {
        __weak typeof(self) weakSelf = self;
        [self enableDfuMode:YES completion:^(NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuEnableFailed;
                NSString* reason = [error localizedDescription];
                NSError* localError = [[strongSelf class] errorWithCode:code reason:reason];
                [strongSelf endDfuWithError:localError];
            } else {
                [strongSelf beginDfuWithURL:url];
            }
        }];
    } else if ([self rediscoveryRequired]) {
        __weak typeof(self) weakSelf = self;
        [self rediscoverThen:^(NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuError;
                NSString* reason = [error localizedDescription];
                NSError* localError = [[strongSelf class] errorWithCode:code reason:reason];
                [strongSelf endDfuWithError:localError];
            } else {
                [strongSelf beginDfuWithURL:url];
            }
        }];
    } else {
        [self beginDfuWithURL:url];
    }
}

- (void)beginDfuWithURL:(NSString*)url {
    NSURL* pathToFirmware = [NSURL URLWithString:url];
    DFUFirmware* firmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:pathToFirmware
                                                              urlToDatFile:nil
                                                                      type:DFUFirmwareTypeApplication];
    
    CBCentralManager* central = [[LGCentralManager sharedInstance] manager];
    CBPeripheral* peripheral = [[[self sleepPill] peripheral] cbPeripheral];
    DFUServiceInitiator* initiator = [[DFUServiceInitiator alloc] initWithCentralManager:central
                                                                                  target:peripheral];
    
    [initiator withFirmwareFile:firmware];
    [initiator setProgressDelegate:self];
    [initiator setDelegate:self];
    
    [self setDfuController:[initiator start]];
}

- (void)endDfuWithError:(NSError*)error {
    if ([self dfuCompletionBlock]) {
        [self dfuCompletionBlock] (error);
        [self setDfuCompletionBlock:nil];
        [self setProgressBlock:nil];
    }
}

#pragma mark Progress

- (void)onUploadProgress:(NSInteger)part
              totalParts:(NSInteger)totalParts
                progress:(NSInteger)progress
currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
  avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    DDLogVerbose(@"upload progress %ld", progress);
    if ([self progressBlock]) {
        [self progressBlock] (progress / 100.0f, [self currentDfuState]);
    }
}

- (void)didStateChangedTo:(enum State)state {
    DDLogVerbose(@"did change state to %ld", (long)state);
    switch (state) {
        case StateAborted: {
            SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuAborted;
            NSError* error = [[self class] errorWithCode:code reason:@"dfu aborted"];
            [self endDfuWithError:error];
            break;
        }
        case StateConnecting:
            [self setCurrentDfuState:SENSleepPillDfuStateConnecting];
            break;
        case StateStarting:
        case StateUploading:
        case StateEnablingDfuMode:
            [self setCurrentDfuState:SENSleepPillDfuStateUpdating];
            break;
        case StateValidating:
            [self setCurrentDfuState:SENSleepPillDfuStateValidating];
            break;
        case StateDisconnecting:
            [self setCurrentDfuState:SENSleepPillDfuStateDisconnecting];
            break;
        case StateCompleted:
            [self setCurrentDfuState:SENSleepPillDfuStateCompleted];
            [self endDfuWithError:nil];
            break;
        default:
            [self setCurrentDfuState:SENSleepPillDfuStateNotStarted];
            break;
    }
}

- (void)didErrorOccur:(enum DFUError)error withMessage:(NSString *)message {
    SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuError;
    NSError* localError = [[self class] errorWithCode:code reason:message];
    [self endDfuWithError:localError];
    [self setRediscoveryRequired:YES];
}

#pragma mark - Clean up

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self isConnected]) {
        [self disconnect:nil];
    }
}

@end
