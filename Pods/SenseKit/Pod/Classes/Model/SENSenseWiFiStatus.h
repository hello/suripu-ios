//
//  SENSenseWiFiStatus.h
//  Pods
//
//  Created by Jimmy Lu on 7/22/15.
//
//

#import <Foundation/Foundation.h>

@class SENSenseMessage;

typedef NS_ENUM(NSInteger, SENWiFiConnectionState) {
    SENWiFiConnectionStateUnknown = -1,
    SENWiFiConnectionStateNotConnectedToNetwork = 0,
    SENWiFiConnectionStateConnectingToNetwork = 1,
    SENWifiConnectionStateConnectedToNetwork = 2,
    SENWiFiConnectionStateObtainedIP = 3,
    SENWiFiConnectionStateDNSResolved = 4,
    SENWiFiConnectionStateSocketConnected = 5,
    SENWiFiConnectionStateRequestSent = 6,
    SENWiFiConnectionStateConnectedToServer = 7,
    SENWiFiConnectionStateSSLFailure = 8,
    SENWiFiConnectionStateHelloKeyFailure = 9,
    SENWiFiConnectionStateDNSFailed = 10,
    SENWiFiConnectionStateServerConnectionFailed = 11
};

@interface SENSenseWiFiStatus : NSObject

@property (nonatomic, assign, readonly) SENWiFiConnectionState state;
@property (nonatomic, copy,   readonly) NSString* httpStatusCode;
@property (nonatomic, assign, readonly) NSInteger socketErrorCode;

- (instancetype)initWithMessage:(SENSenseMessage*)message;
- (BOOL)encounteredError;
- (BOOL)isConnected;

@end
