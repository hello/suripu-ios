//
//  SENSenseWiFiStatus.m
//  Pods
//
//  Created by Jimmy Lu on 7/22/15.
//
//

#import "SENSenseWiFiStatus.h"
#import "SENSenseMessage.pb.h"

@interface SENSenseWiFiStatus()

@property (nonatomic, assign) SENSenseMessageType messageType;
@property (nonatomic, assign) SENWiFiConnectionState state;
@property (nonatomic, copy)   NSString* httpStatusCode;
@property (nonatomic, assign) NSInteger socketErrorCode;
@property (nonatomic, assign, getter=hasErrorInMessage) BOOL errorInMessage;

@end

@implementation SENSenseWiFiStatus

- (instancetype)initWithMessage:(SENSenseMessage*)message {
    self = [super init];
    if (self) {
        [self extractStatusFromMessage:message];
    }
    return self;
}

- (void)extractStatusFromMessage:(SENSenseMessage*)message {
    if ([message hasHttpResponseCode]) {
        [self setHttpStatusCode:[message httpResponseCode]];
    }
    
    if ([message hasSocketErrorCode]) {
        [self setSocketErrorCode:[message socketErrorCode]];
    }
    
    if ([message hasWifiState]) {
        // connection state and wifi state's value map 1-1, with the exception
        // of unknown, which will be the default value of -1
        [self setState:(SENWiFiConnectionState)[message wifiState]];
    }
    
    if ([message hasType]) {
        [self setMessageType:[message type]];
    }
    
    [self setErrorInMessage:[message hasError]];
}


- (BOOL)encounteredError {
    // ignore SENWiFiConnectionStateDNSFailed and SENWiFiConnectionStateServerConnectionFailed
    // as Sense will attempt retry the connection
    return [self state] == SENWiFiConnectionStateSSLFailure
        || [self state] == SENWiFiConnectionStateHelloKeyFailure
        || [self hasErrorInMessage];
}

- (BOOL)isConnected {
    return ([self messageType] == SENSenseMessageTypeConnectionState
         && [self state] == SENWiFiConnectionStateConnectedToServer)
         ||([self messageType] != SENSenseMessageTypeConnectionState
         && [self state] == SENWiFiConnectionStateObtainedIP);
}

- (NSString *)description {
    static NSString* const format =  @"<SENSenseWiFiStatus state=%ld, httpStatus=%@, socketError=%ld>";
    return [NSString stringWithFormat:format, (long)[self state], [self httpStatusCode], [self socketErrorCode]];
}

@end
