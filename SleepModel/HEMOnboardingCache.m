
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSenseManager.h>
#import <SenseKit/SENAPIDevice.h>
#import <SenseKit/SENSense.h>

#import "HEMOnboardingCache.h"
#import "HEMBluetoothUtils.h"

static CGFloat   const HEMOnboardingCacheSensorPollIntervalDelay = 5.0f;
static NSInteger const HEMOnboardingCacheMaxSensorPollingAttempts = 10;
static NSInteger const HEMOnboardingCacheMaxSenseScanAttempts = 10;
static HEMOnboardingCache* sharedUserDataCache = nil;

@interface HEMOnboardingCache()

@property (nonatomic, assign) NSInteger sensorPollingAttempts;
@property (nonatomic, assign) NSInteger senseScanAttempts;
@property (nonatomic, copy)   NSArray* nearbySensesFound;
@property (nonatomic, copy)   NSNumber* pairedAccountsToSense;
@property (nonatomic, assign) BOOL pollingSensor;

@end

@implementation HEMOnboardingCache

+ (instancetype)sharedCache
{
    if (!sharedUserDataCache) {
        sharedUserDataCache = [HEMOnboardingCache new];
    }
    return sharedUserDataCache;
}

+ (void)clearCache
{
    sharedUserDataCache = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setSensorPollingAttempts:0];
        [self setSenseScanAttempts:0];
    }
    return self;
}

- (void)startPollingSensorData
{
    if (![self pollingSensor]
        && [self sensorPollingAttempts] < HEMOnboardingCacheMaxSensorPollingAttempts) {
        
        [self setSensorPollingAttempts:[self sensorPollingAttempts]+1];
        [self setPollingSensor:YES];
        
        NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
        __weak typeof(self) weakSelf = self;
        __weak __block id observer =
        [center addObserverForName:SENSensorsUpdatedNotification
                            object:nil
                             queue:[NSOperationQueue mainQueue]
                        usingBlock:^(NSNotification *note) {
                            __strong typeof(weakSelf) strongSelf = weakSelf;
                            
                            [[NSNotificationCenter defaultCenter] removeObserver:observer];
                            
                            if (strongSelf) {
                                [strongSelf setPollingSensor:NO];
                                
                                NSArray* sensors = [SENSensor sensors];
                                NSInteger sensorCount = [sensors count];
                                DDLogVerbose(@"sensors returned %ld", (long)sensorCount);
                                if (sensorCount == 0
                                    || [((SENSensor*)sensors[0]) condition] == SENConditionUnknown) {
                                    int64_t delayInSec = (int64_t)(HEMOnboardingCacheSensorPollIntervalDelay * NSEC_PER_SEC);
                                    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, delayInSec);
                                    dispatch_after(delay, dispatch_get_main_queue(), ^{
                                        [strongSelf startPollingSensorData];
                                    });
                                    
                                }
                            }

                        }];
        
        DDLogVerbose(@"polling for sensor data during onboarding");
        [SENSensor refreshCachedSensors];
    } else {
        DDLogVerbose(@"polling stopped, attempts %ld", (long)[self sensorPollingAttempts]);
    }
    
}

- (void)preScanForSenses {
    if ([self senseScanAttempts] == HEMOnboardingCacheMaxSenseScanAttempts
        || ([HEMBluetoothUtils stateAvailable]
            && ![HEMBluetoothUtils isBluetoothOn])) {
        return;
    }
    
    float retryInterval = 0.2f;
    
    [SENSenseManager stopScan]; // stop a scan if one is in progress;
    
    DDLogVerbose(@"pre-scanning for nearby senses");
    __weak typeof(self) weakSelf = self;
    [self setSenseScanAttempts:[self senseScanAttempts] + 1];
    
    if (![SENSenseManager scanForSense:^(NSArray *senses) {
        DDLogVerbose(@"found some senses to cache %@", senses);
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if ([senses count] == 0) {
            [strongSelf performSelector:@selector(preScanForSenses)
                             withObject:nil
                             afterDelay:retryInterval];
        } else {
            [strongSelf setNearbySensesFound:senses];
        }
    }]) {
        [self performSelector:@selector(preScanForSenses)
                   withObject:nil
                   afterDelay:retryInterval];
    }
}

- (void)clearPreScannedSenses {
    [self setNearbySensesFound:nil];
}

- (void)checkNumberOfPairedAccounts {
    // ask the server if how many accounts exist for this Sense and cache result
    NSString* deviceId = [[[self senseManager] sense] deviceId];
    if ([deviceId length] > 0) {
        __weak typeof(self) weakSelf = self;
        [SENAPIDevice getNumberOfAccountsForPairedSense:deviceId completion:^(NSNumber* pairedAccounts, NSError *error) {
            DDLogVerbose(@"sense %@ has %ld account paired to it", deviceId, [pairedAccounts longValue]);
            [weakSelf setPairedAccountsToSense:pairedAccounts];
        }];
    }
}

@end
