//
//  HEMExpansionService.m
//  Sense
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <SenseKit/SENSenseMetadata.h>
#import <SenseKit/SENAPIExpansion.h>
#import <SenseKit/SENExpansion.h>
#import <SenseKit/SENService+Protected.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEMExpansionService.h"
#import "HEMMathUtil.h"

static NSString* const HEMExpansionLightCategory = @"LIGHT";

@interface HEMExpansionService()

@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;

@end

@implementation HEMExpansionService

#pragma mark - Service events

- (void)serviceReceivedMemoryWarning {
    [super serviceReceivedMemoryWarning];
    [self setExpansions:nil];
}

#pragma mark - Interface methods

- (BOOL)isEnabledForHardware:(SENSenseHardware)hardware {
    return hardware == SENSenseHardwareVoice;
}

- (BOOL)isConnected:(SENExpansion*)expansion {
    switch ([expansion state]) {
        case SENExpansionStateRevoked:
        case SENExpansionStateNotConnected:
        case SENExpansionStateUnknown:
            return NO;
        default:
            return YES;
    }
}

- (BOOL)isReadyForUse:(SENExpansion*)expansion {
    return [expansion state] == SENExpansionStateConnectedOn;
}

- (SENExpansion*)firstExpansionOfType:(SENExpansionType)type
                         inExpansions:(NSArray<SENExpansion*>*)expansions {
    SENExpansion* firstExpansion = nil;
    for (SENExpansion* expansion in expansions) {
        if ([expansion type] == type) {
            firstExpansion = expansion;
            break;
        }
    }
    return firstExpansion;
}

- (NSURLRequest*)authorizationRequestForExpansion:(SENExpansion*)expansion {
    NSURL* url = [NSURL URLWithString:[expansion authUri]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    return [SENAuthorizationService authorizeRequest:request];
}

- (BOOL)hasExpansion:(SENExpansion*)expansion connectedWithURL:(NSURL*)url {
    NSString* currentUrl = [[url absoluteString] lowercaseString];
    NSString* doneUrl = [[expansion authCompletionUri] lowercaseString];
    return [currentUrl hasPrefix:doneUrl];
}

- (void)getListOfExpansion:(HEMExpansionListHandler)completion {
    __weak typeof (self) weakSelf = self;
    [SENAPIExpansion getSupportedExpansions:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            [strongSelf setExpansions:data];
        }
        completion (data, error);
    }];
}

- (void)updateExpansionState:(SENExpansion*)expansion
                  completion:(HEMExpansionUpdateHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIExpansion updateExpansionStateFor:expansion completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = self;
        if (error) {
            [SENAnalytics trackError:error];
        } else {
            // invalidate the cache
            [strongSelf setExpansions:nil];
        }
        completion (error);
    }];
}

- (void)enable:(BOOL)enable expansion:(SENExpansion*)expansion completion:(HEMExpansionUpdateHandler)completion {
    SENExpansionState currentState = [expansion state];
    SENExpansionState newState = enable ? SENExpansionStateConnectedOn : SENExpansionStateConnectedOff;
    [expansion setState:newState];
    
    [self updateExpansionState:expansion completion:^(NSError * _Nullable error) {
        if (error) {
            // revert
            [expansion setState:currentState];
        }
        completion (error);
    }];
}

- (void)removeExpansion:(SENExpansion*)expansion completion:(HEMExpansionUpdateHandler)completion {
    SENExpansionState currentState = [expansion state];
    [expansion setState:SENExpansionStateRevoked];
    
    __weak typeof(self) weakSelf = self;
    [self updateExpansionState:expansion completion:^(NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            // revert
            [expansion setState:currentState];
        } else {
            [strongSelf setExpansions:nil];
        }
        completion (error);
    }];
}

- (void)refreshExpansion:(SENExpansion*)expansion completion:(HEMExpansionHandler)completion {
    __weak typeof (self) weakSelf = self;
    NSString* expansionId = [[expansion identifier] stringValue];
    [SENAPIExpansion getExpansionById:expansionId completion:^(id data, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [SENAnalytics trackError:error];
        } else if ([strongSelf expansions]) {
            SENExpansion* updatedExpansion = data;
            NSInteger count = [[strongSelf expansions] count];
            NSMutableArray<SENExpansion*>* updatedExpansions = [NSMutableArray arrayWithCapacity:count];
            for (SENExpansion* cachedExpansion in [strongSelf expansions]) {
                if ([[cachedExpansion identifier] isEqual:[expansion identifier]]
                    && updatedExpansion) {
                    [updatedExpansions addObject:updatedExpansion];
                } else {
                    [updatedExpansions addObject:cachedExpansion];
                }
            }
            [strongSelf setExpansions:updatedExpansions];
        }
        completion (data, error);
    }];
}

#pragma mark - Configurations

- (void)getConfigurationsForExpansion:(SENExpansion*)expansion completion:(HEMExpansionConfigHandler)completion {
    [SENAPIExpansion getExpansionConfigurationsFor:expansion completion:^(id data, NSError *error) {
        if (error) {
            [SENAnalytics trackError:error];
        }
        completion (data, error);
    }];
}

- (void)setConfiguration:(SENExpansionConfig*)config
            forExpansion:(SENExpansion*)expansion
              completion:(HEMExpansionHandler)completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIExpansion setExpansionConfiguration:config forExpansion:expansion completion:^(id data, NSError *updateError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (updateError) {
            [SENAnalytics trackError:updateError];
            completion (nil, updateError);
        } else {
            [strongSelf refreshExpansion:expansion completion:^(SENExpansion * expansion, NSError * error) {
                // ignore this error
                if (completion) {
                    completion (expansion, nil);
                }
            }];
        }
    }];
}

- (NSString*)configurationNameForExpansion:(SENExpansion*)expansion {
    switch ([expansion type]) {
        case SENExpansionTypeLights:
            return NSLocalizedString(@"expansion.configuration.name.light", nil);
        case SENExpansionTypeThermostat:
            return NSLocalizedString(@"expansion.configuration.name.temperature", nil);
        default:
            return NSLocalizedString(@"expansion.configuration.name.generic", nil);
    }
}

#pragma mark - Conversions

- (SENExpansionValueRange)convertThermostatRangeToCelsis:(SENExpansionValueRange)range {
    SENExpansionValueRange convertedRange = range;
    convertedRange.min = HEMFahrenheitToCelsius(range.min);
    convertedRange.max = HEMFahrenheitToCelsius(range.max);
    convertedRange.setpoint = HEMFahrenheitToCelsius(range.setpoint);
    return convertedRange;
}

- (SENExpansionValueRange)convertThermostatRangeBasedOnPreference:(SENExpansionValueRange)range {
    SENExpansionValueRange convertedRange = range;
    // server servers celsius
    if ([SENPreference temperatureFormat] == SENTemperatureFormatFahrenheit) {
        convertedRange.min = ceil(HEMCelsiusToFahrenheit(range.min));
        convertedRange.max = ceil(HEMCelsiusToFahrenheit(range.max));
        convertedRange.setpoint = ceil(HEMCelsiusToFahrenheit(range.setpoint));
    }
    
    return convertedRange;
}

@end
