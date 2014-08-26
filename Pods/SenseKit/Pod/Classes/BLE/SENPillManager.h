
#import <Foundation/Foundation.h>

@class LGPeripheral;
@class LGCentralManager;

typedef void (^SENDeviceErrorBlock)(NSError* error);

extern NSString* const SENDeviceServiceELLO;
extern NSString* const SENDeviceServiceFFA0;

/**
 *  Notification identifier sent when current time is set on a peripheral
 */
extern NSString* const SENDeviceManagerDidWriteCurrentTimeNotification;

@interface SENPillManager : NSObject

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;

- (void)writeCurrentTimeWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)readCurrentTimeWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)calibrateWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)startDataCollectionWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)stopDataCollectionWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)disconnectWithCompletion:(SENDeviceErrorBlock)completionBlock;

- (void)fetchDataWithCompletion:(SENDeviceErrorBlock)completionBlock;

/**
 *  A list of discovered named devices, populated by calling `scanForPeripherals`
 */
@property (nonatomic, strong, readonly) NSArray* discoveredPeripherals;

/**
 *  The connected peripheral
 */
@property (nonatomic, strong, readonly) LGPeripheral* peripheral;

@end
