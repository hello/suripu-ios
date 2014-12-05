
#import <SenseKit/SENAccount.h>
#import <SenseKit/SENSensor.h>

#import "HEMUserDataCache.h"

static CGFloat   const HEMUserDataCacheSensorPollIntervalDelay = 5.0f;
static NSInteger const HEMUserDataCacheMaxSensorPollingAttempts = 10;
static HEMUserDataCache* sharedUserDataCache = nil;

@interface HEMUserDataCache()

@property (nonatomic, assign) NSInteger sensorPollingAttempts;

@end

@implementation HEMUserDataCache

+ (instancetype)sharedUserDataCache
{
    if (!sharedUserDataCache) {
        sharedUserDataCache = [HEMUserDataCache new];
    }
    return sharedUserDataCache;
}

+ (void)clearSharedUserDataCache
{
    sharedUserDataCache = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setSensorPollingAttempts:0];
    }
    return self;
}

- (void)startPollingSensorData
{
    if (![self pollingSensor]
        && [self sensorPollingAttempts] < HEMUserDataCacheMaxSensorPollingAttempts) {
        
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
                                    || [((SENSensor*)sensors[0]) condition] == SENSensorConditionUnknown) {
                                    int64_t delayInSec = (int64_t)(HEMUserDataCacheSensorPollIntervalDelay * NSEC_PER_SEC);
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

@end
