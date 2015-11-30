//
//  HEMSenseSettingsDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HEMDeviceWarning;

typedef void(^HEMSenseSettingsWarningBlock)(NSOrderedSet<HEMDeviceWarning*>* _Nonnull warnings);
typedef void(^HEMSenseSettingsActionBlock)(NSError* _Nullable error);
typedef void(^HEMSenseSettingsDisconnectBlock)(NSError* _Nullable error);

@interface HEMSenseSettingsDataSource : NSObject

- (void)checkForWarnings:(nonnull HEMSenseSettingsWarningBlock)completion;
- (void)unlinkSense:(nonnull HEMSenseSettingsActionBlock)completion;
- (void)updateToLocalTimeZone:(nonnull HEMSenseSettingsActionBlock)completion;
- (void)enablePairingMode:(nonnull HEMSenseSettingsActionBlock)completion;
- (void)factoryReset:(nonnull HEMSenseSettingsDisconnectBlock)completion;
- (BOOL)isConnectedToSense;
- (nonnull NSOrderedSet*)deviceWarnings;
- (void)setDisconnectHandler:(nonnull HEMSenseSettingsDisconnectBlock)disconnectHandler;

@end
