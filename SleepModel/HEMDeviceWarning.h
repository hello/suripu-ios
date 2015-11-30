//
//  HEMDeviceWarning.h
//  Sense
//
//  Created by Jimmy Lu on 11/18/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HEMDeviceWarningType) {
    HEMDeviceWarningTypeLastSeen = 1,
    HEMDeviceWarningTypeSenseLostServerConnection = 2,
    HEMDeviceWarningTypeSenseNotConnectedOverBLE = 3,
    HEMDeviceWarningTypePillHasLowBattery = 4
};

@interface HEMDeviceWarning : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString* localizedSummary;
@property (nonatomic, copy, readonly, nonnull) NSAttributedString* localizedMessage;
@property (nonatomic, copy, readonly, nullable) NSString* supportPage;
@property (nonatomic, assign, readonly) HEMDeviceWarningType type;

- (nonnull instancetype)initWithType:(HEMDeviceWarningType)type
                             summary:(nonnull NSString*)localizedSummary
                             message:(nonnull NSAttributedString*)localizedMessage
                         supportPage:(nullable NSString*)supportPage;

@end
