//
//  HEMWifiConfigurationDelegate.h
//  Sense
//
//  Created by Jimmy Lu on 11/4/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

@protocol HEMWiFiConfigurationDelegate <NSObject>

- (void)didConfigureWiFiTo:(NSString*)ssid from:(id)controller;
- (void)didCancelWiFiConfigurationFrom:(id)controller;

@optional
- (BOOL)shouldShowMacAddress:(BOOL)show from:(id)controller;

@end
