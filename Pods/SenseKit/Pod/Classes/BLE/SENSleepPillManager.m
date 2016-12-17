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

static NSInteger const SENSleepPillDFUDelayInSecs = 1.5f;
static NSInteger const SENSleepPillMaxScanPeripherals = 200;
static CGFloat const SENSleepPillDefaultScanTimeout = 10.0f;
static CGFloat const SENSleepPillConnectionTimeout = 10.0f;
static int8_t const SENSleepPillDfuPayload = 8;
static CGFloat const SENSleepPillDfuDelay = 5.0f;
static NSTimeInterval const SENSleepPillEnableDfuTimeout = 10.0f + SENSleepPillDefaultScanTimeout;
static NSTimeInterval const SENSleepPillDfuTimeout = 20.0f + SENSleepPillDefaultScanTimeout;

@interface SENSleepPillManager() <DFUProgressDelegate, DFUServiceDelegate, LoggerDelegate>

@property (nonatomic, strong) SENSleepPill* sleepPill;
@property (nonatomic, strong) DFUServiceController* dfuController;
@property (nonatomic, copy) SENSleepPillManagerProgressBlock progressBlock;
@property (nonatomic, copy) SENSleepPillManagerDFUBlock dfuCompletionBlock;
@property (nonatomic, copy) SENSleepPillResponseHandler enableDfuBlock;
@property (nonatomic, assign) SENSleepPillDfuState currentDfuState;
@property (nonatomic, assign) BOOL rediscoveryRequired;
@property (nonatomic, strong) NSTimer* timeoutTimer;
@property (nonatomic, strong) NSURL* localDFUBinaryFileURL;
@property (nonatomic, assign) NSInteger dfuProgress;

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
    [self scanForMaxSleepPills:SENSleepPillMaxScanPeripherals completion:completion];
}

+ (void)scanForMaxSleepPills:(NSInteger)maxSleepPills completion:(SENSleepPillManagerScanBlock)completion {
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
                CBUUID* serviceId = [CBUUID UUIDWithString:SENSleepPillServiceUUID];
                CBUUID* dfuServiceId = [CBUUID UUIDWithString:SENSleepPillDfuServiceUUID];
                
                sleepPills = [NSMutableArray arrayWithCapacity:count];
                for (LGPeripheral* peripheral in peripherals) {
                    NSDictionary* advertisement = [peripheral advertisingData];
                    NSArray* serviceIds = [advertisement objectForKey:CBAdvertisementDataServiceUUIDsKey];
                    if ([serviceIds containsObject:serviceId] || [serviceIds containsObject:dfuServiceId]) {
                        [sleepPills addObject:[[SENSleepPill alloc] initWithPeripheral:peripheral]];
                    }
                }
            }
            completion (sleepPills, nil);
        };
        // since the pill can be in either mode (dfu / normal), we need to support
        // multiple services.  however, CoreBluetooth's scan API is an AND not an
        // OR when it comes to services, which means we need to pass in nil and
        // filter the results instead.  This is inefficient!
        dispatch_async(dispatch_get_main_queue(), ^{
            // always scan from the main thread!
            LGCentralManager* central = [LGCentralManager sharedInstance];
            [[central manager] stopScan];
            [[central manager] setDelegate:central];
            [central setPeripheralsCountToStop:maxSleepPills];
            [central scanForPeripheralsByInterval:SENSleepPillDefaultScanTimeout
                                         services:nil
                                          options:nil
                                       completion:scanDone];
        });
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
    
    void(^rescan)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DDLogVerbose(@"rescanning for pill peripheral");
        [[strongSelf class] scanForSleepPills:^(NSArray<SENSleepPill *> * _Nullable pills, NSError * _Nullable error) {
            if (error || [pills count] == 0) {
                fail ( error );
            } else {
                for (SENSleepPill* pill in pills) {
                    if ([[pill identifier] isEqualToString:[[strongSelf sleepPill] identifier]]) {
                        [strongSelf setSleepPill:pill];
                        [strongSelf setRediscoveryRequired:NO];
                        completion (nil);
                        return;
                    }
                }
                // if out of the loop without returning, fail
                fail ( nil );
            }
        }];
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSUUID* existingUUID = [[NSUUID alloc] initWithUUIDString:[[strongSelf sleepPill] identifier]];
        NSArray* peripherals = [[LGCentralManager sharedInstance] retrievePeripheralsWithIdentifiers:@[existingUUID]];
        if ([peripherals count] == 1 && ![strongSelf rediscoveryRequired]) {
            [strongSelf setRediscoveryRequired:NO];
            [strongSelf setSleepPill:[[SENSleepPill alloc] initWithPeripheral:[peripherals firstObject]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (nil);
            });
        } else {
            rescan();
        }
    });
}

- (BOOL)operationInProgress {
    return [self enableDfuBlock] != nil
    || [self dfuCompletionBlock] != nil;
}

#pragma mark - Timeout

- (void)scheduleOperationTimeout:(NSTimeInterval)timeoutInSecs action:(SEL)action {
    [self cancelTimeout];
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:timeoutInSecs
                                                      target:self
                                                    selector:action
                                                    userInfo:nil
                                                     repeats:NO];
    [self setTimeoutTimer:timer];
}

- (void)cancelTimeout {
    [[self timeoutTimer] invalidate];
    [self setTimeoutTimer:nil];
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
    [self cancelTimeout];
    
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

+ (BOOL)isSleepPillInDFUMode:(SENSleepPill*)pill {
    LGPeripheral* peripheral = [pill peripheral];
    NSDictionary* advertisingData = [peripheral advertisingData];
    NSArray* serviceIds = [advertisingData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    CBUUID* dfuServiceId = [CBUUID UUIDWithString:SENSleepPillDfuServiceUUID];
    return [serviceIds containsObject:dfuServiceId];
}

- (void)enableDfuTimeout {
    [self setTimeoutTimer:nil];
    
    [[[LGCentralManager sharedInstance] manager] stopScan];
    DDLogVerbose(@"enable dfu timed out");
    
    if ([self enableDfuBlock]) {
        SENSleepPillErrorCode code = SENSleepPillErrorCodeTimeout;
        NSString* reason = @"enabling dfu timed out";
        NSError* error = [[self class] errorWithCode:code reason:reason];
        [self enableDfuBlock] (error);
        [self setEnableDfuBlock:nil];
    }
}

- (BOOL)isInDfuMode {
    if ([self currentDfuState] != SENSleepPillDfuStateNotStarted
        && [self currentDfuState] != SENSleepPillDfuStateCompleted
        && [self currentDfuState] != SENSleepPillDfuStateError) {
        DDLogVerbose(@"current dfu state indicate it's already in dfu mode");
        return YES;
    }
    return [[self class] isSleepPillInDFUMode:[self sleepPill]];
}

- (void)enableDfuMode:(BOOL)enable completion:(SENSleepPillResponseHandler)completion {
    if ([self isInDfuMode]) {
        return completion (nil);
    }
    
    [self setEnableDfuBlock:completion];
    [self listenForUnexpectedDisconnects];
    [self scheduleOperationTimeout:SENSleepPillEnableDfuTimeout action:@selector(enableDfuTimeout)];
    
    __weak typeof(self) weakSelf = self;
    void(^done)(NSError* error) = ^(NSError* error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf cancelTimeout];
        [strongSelf enableDfuBlock] (error);
        [strongSelf setEnableDfuBlock:nil];
    };
    
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
                                            [write writeByte:SENSleepPillDfuPayload completion:done];
                                        } else {
                                            SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuMissingCharacteristic;
                                            NSString* reason = @"characteristic not found";
                                            NSError* error = [[strongSelf class] errorWithCode:code reason:reason];
                                            done (error);
                                        }
                                    } else {
                                        done (error);
                                    }
                                }];
    }];
}

- (void)dfuTimeout {
    [self setTimeoutTimer:nil];
    DDLogVerbose(@"dfu timed out");
    
    if ([self dfuCompletionBlock]) {
        SENSleepPillErrorCode code = SENSleepPillErrorCodeTimeout;
        NSString* reason = @"dfu timed out";
        NSError* error = [[self class] errorWithCode:code reason:reason];
        [self dfuCompletionBlock] (error);
        [self setDfuCompletionBlock:nil];
    }
}

- (void)performDFUWithURL:(NSString*)url
                 progress:(SENSleepPillManagerProgressBlock)progress
               completion:(SENSleepPillManagerDFUBlock)completion {
    
    if ([self dfuCompletionBlock]) {
        SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuInProgress;
        completion ([[self class] errorWithCode:code reason:@"a dfu is in progress"]);
        return;
    }
    
    [self setCurrentDfuState:SENSleepPillDfuStateNotStarted];
    [self setProgressBlock:progress];
    [self setDfuCompletionBlock:completion];
    [self listenForUnexpectedDisconnects];
    [self scheduleOperationTimeout:SENSleepPillDfuTimeout action:@selector(dfuTimeout)];
    
    __weak typeof(self) weakSelf = self;
    void(^enableDfuFirst)(void) = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf enableDfuMode:YES completion:^(NSError * error) {
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
    };
    
    if ([self rediscoveryRequired]) {
        __weak typeof(self) weakSelf = self;
        [self rediscoverThen:^(NSError * error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error) {
                SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuError;
                NSString* reason = [error localizedDescription];
                NSError* localError = [[strongSelf class] errorWithCode:code reason:reason];
                [strongSelf endDfuWithError:localError];
            } else if (![strongSelf isInDfuMode]) {
                enableDfuFirst();
            } else {
                [strongSelf beginDfuWithURL:url];
            }
        }];
    } else if (![self isInDfuMode]) {
        enableDfuFirst();
    } else {
        [self beginDfuWithURL:url];
    }
}

- (NSURL*)saveFirmwareBinaryData:(NSData*)data withOriginalURL:(NSURL*)url error:(NSError**)error {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* docsDir = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString* origFileName = [url lastPathComponent];
    NSString* localPath = [[docsDir path] stringByAppendingPathComponent:origFileName];
    NSURL* localURL = [NSURL fileURLWithPath:localPath];
    [data writeToURL:localURL options:NSDataWritingAtomic error:error];
    return localURL;
}

- (void)removeLocalFirmwareBinaryIfExists:(NSURL*)pathToLocalFile {
    if (pathToLocalFile) {
        DDLogVerbose(@"removing local binary file");
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError* error = nil;
        [fileManager removeItemAtURL:pathToLocalFile error:&error];
    }
}

- (void)beginDfuWithURL:(NSString*)url {
    __weak typeof(self) weakSelf = self;
    NSURL* pathToFirmware = [NSURL URLWithString:url];
    NSURLSession* session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:pathToFirmware
            completionHandler:^(NSData* data, NSURLResponse* response, NSError*  error) {
                DDLogVerbose(@"downloaded binary in main thread (%@)",
                             [NSThread isMainThread] ? @"y" : @"n");
                
                __weak typeof(weakSelf) strongSelf = weakSelf;
                NSHTTPURLResponse* httpResponse = (id) response;
                if (error) {
                    [strongSelf endDfuWithError:error];
                } else if ([httpResponse statusCode] == 200 && [data length] > 0) {
                    NSError* saveError = nil;
                    NSURL* localFileURL = [strongSelf saveFirmwareBinaryData:data
                                                             withOriginalURL:pathToFirmware
                                                                       error:&saveError];
                    if (saveError) {
                        [strongSelf endDfuWithError:saveError];
                    } else {
                        [strongSelf setLocalDFUBinaryFileURL:localFileURL];
                        [strongSelf beginDfuWithLocalURL:localFileURL];
                    }
                } else {
                    SENSleepPillErrorCode code = SENSleepPillErrorCodeUnableToDownloadUpdate;
                    NSString* reason = [NSString stringWithFormat:@"failed to download binary with status code %ld",
                                        (long) [httpResponse statusCode]];
                    NSError* error = [[strongSelf class] errorWithCode:code reason:reason];
                    [strongSelf endDfuWithError:error];
                }
            }] resume];
}

- (void)beginDfuWithLocalURL:(NSURL*)localURL {
    DDLogVerbose(@"starting DFU after delay");
    // initialization of the DFUFirmware using the localURL will load the binary
    // synchronously and thus should be kept in the background thread.
    DFUFirmware* firmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:localURL
                                                              urlToDatFile:nil
                                                                      type:DFUFirmwareTypeApplication];
    
    __weak typeof(self) weakSelf = self;
    int64_t delayInSecs = (int64_t)(SENSleepPillDfuDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSecs);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        LGCentralManager* central = [LGCentralManager sharedInstance];
        CBCentralManager* manager = [central manager];
        CBPeripheral* peripheral = [[[strongSelf sleepPill] peripheral] cbPeripheral];
        DFUServiceInitiator* initiator = [[DFUServiceInitiator alloc] initWithCentralManager:manager
                                                                                      target:peripheral];
        [initiator setLogger:strongSelf];
        [initiator withFirmwareFile:firmware];
        [initiator setProgressDelegate:strongSelf];
        [initiator setDelegate:strongSelf];
        
        [strongSelf setDfuController:[initiator start]];
    });
}

- (void)endDfuWithError:(NSError*)error {
    __weak typeof(self) weakSelf = self;
    void (^end)(void) = ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf cancelTimeout];
        [strongSelf disconnect:nil];
        [strongSelf removeLocalFirmwareBinaryIfExists:[strongSelf localDFUBinaryFileURL]];
        [strongSelf setDfuProgress:0];
        
        if ([strongSelf dfuCompletionBlock]) {
            [strongSelf dfuCompletionBlock] (error);
            [strongSelf setDfuCompletionBlock:nil];
            [strongSelf setDfuController:nil];
            [strongSelf setProgressBlock:nil];
        }
        
        // FIXME: this is a hacky workaround for the fact that Nordic takes over the
        // delegate of the CentralManager and never resets it.  Ideally Nordic would
        // fix this by creating their own central, or reverting their delegate changes.
        LGCentralManager* centralManager = [LGCentralManager sharedInstance];
        CBCentralManager* cbCentral = [centralManager manager];
        [cbCentral stopScan];
        [cbCentral setDelegate:centralManager];
        
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), end);
    } else {
        end();
    }
    
}

#pragma mark Progress

- (void)onUploadProgress:(NSInteger)part
              totalParts:(NSInteger)totalParts
                progress:(NSInteger)progress
currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
  avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    DDLogVerbose(@"upload progress %ld", progress);
    [self setDfuProgress:progress];
    [self scheduleOperationTimeout:SENSleepPillDfuTimeout action:@selector(dfuTimeout)];
    if ([self progressBlock]) {
        [self progressBlock] (progress / 100.0f, [self currentDfuState]);
    }
}

- (void)didStateChangedTo:(enum DFUState)state {
    [self scheduleOperationTimeout:SENSleepPillDfuTimeout action:@selector(dfuTimeout)];
    DDLogVerbose(@"did change state to %ld", (long)state);
    switch (state) {
        case DFUStateAborted: {
            SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuAborted;
            NSError* error = [[self class] errorWithCode:code reason:@"dfu aborted"];
            [self endDfuWithError:error];
            [self setCurrentDfuState:SENSleepPillDfuStateError];
            break;
        }
        case DFUStateConnecting:
            [self setCurrentDfuState:SENSleepPillDfuStateConnecting];
            break;
        case DFUStateStarting:
        case DFUStateUploading:
        case DFUStateEnablingDfuMode:
            [self setCurrentDfuState:SENSleepPillDfuStateUpdating];
            break;
        case DFUStateValidating:
            [self setCurrentDfuState:SENSleepPillDfuStateValidating];
            break;
        case DFUStateDisconnecting:
            [self setCurrentDfuState:SENSleepPillDfuStateDisconnecting];
            break;
        case DFUStateCompleted: {
            NSError* error = nil;
            if ([self dfuProgress] == 100) {
                [self setCurrentDfuState:SENSleepPillDfuStateCompleted];
            } else {
                [self setCurrentDfuState:SENSleepPillDfuStateError];
                error = [[self class] errorWithCode:SENSleepPillErrorCodeDfuError
                                             reason:@"completed without actually completing"];
            }
            [self endDfuWithError:error];
            break;
        }
        default:
            [self setCurrentDfuState:SENSleepPillDfuStateNotStarted];
            break;
    }
}

- (void)didErrorOccur:(enum DFUError)error withMessage:(NSString *)message {
    SENSleepPillErrorCode code = SENSleepPillErrorCodeDfuError;
    NSError* localError = [[self class] errorWithCode:code reason:message];
    [self endDfuWithError:localError];
    [self setCurrentDfuState:SENSleepPillDfuStateError];
    [self setRediscoveryRequired:YES];
}

#pragma mark - Logger Delegate

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message {
    DDLogVerbose(@"dfu message %@", message);
}

#pragma mark - Clean up

- (void)dealloc {
    [[[LGCentralManager sharedInstance] manager] stopScan];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimeout];
    
    if ([self isConnected]) {
        [self disconnect:nil];
    }
    
    if (_localDFUBinaryFileURL) {
        [self removeLocalFirmwareBinaryIfExists:_localDFUBinaryFileURL];
    }
}

@end
