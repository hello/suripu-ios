//
//  HEMWifiCenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WiFiRssiSignalStrength) {
    WiFiRssiSignalStrengthNone,
    WiFiRssiSignalStrengthLow,
    WiFiRssiSignalStrengthMedium,
    WiFiRssiSignalStrengthHigh
};

@interface HEMWifiUtils : NSObject

/**
 * Obtain information, mainly the SSID, of the currently connected
 * wifi.  If the device is not connected, nil is returned
 * @return dictionary with the info.
 */
+ (NSDictionary*)connectedWifiInfo;

/**
 * Convenience method to obtain the currently connected WIFI SSID.
 * If device is not connected to WIFI, it will simply return nil
 * @return ssid of connected WIFI
 */
+ (NSString*)connectedWifiSSID;

/**
 * Convenience method to return wifi signal icon based ont he rssi value
 * specified.
 * @param rssi value for the wifi endpoint
 * @return the wifi icon image that represents the strength of the signal
 */
+ (UIImage*)wifiIconForRssi:(long)rssi;

@end
