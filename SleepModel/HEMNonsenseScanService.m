//
//  HEMNonsenseScanService.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNonsenseScanService.h"
#import <sys/socket.h>
#import <arpa/inet.h>

typedef union {
    struct sockaddr sa;
    struct sockaddr_in ipv4;
    struct sockaddr_in6 ipv6;
} ip_socket_address;

static NSString* const ServiceType = @"_http._tcp.";
static NSString* const ServiceName = @"nonsense-server";
static NSTimeInterval const ResolveTimeout = 5.0;

@interface HEMNonsenseScanService ()

@property (nonatomic) NSMutableArray<NSNetService*>* discovering;
@property (nonatomic) NSNetServiceBrowser* netServiceBrowser;

@end

@implementation HEMNonsenseScanService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.discovering = [NSMutableArray array];
        self.netServiceBrowser = [NSNetServiceBrowser new];
        self.netServiceBrowser.delegate = self;
    }
    return self;
}

- (void)start {
    [self.netServiceBrowser searchForServicesOfType:ServiceType inDomain:@"local"];
}

- (void)stop {
    [self.netServiceBrowser stop];
    
    for (NSNetService* service in self.discovering) {
        [service stop];
        service.delegate = nil;
    }
    [self.discovering removeAllObjects];
}

#pragma mark -

- (nonnull NSString*)addressForNonsense:(nonnull NSNetService*)nonsense {
    const ip_socket_address* socketAddress = nonsense.addresses.firstObject.bytes;
    if (socketAddress) {
        char addressBuffer[INET6_ADDRSTRLEN];
        switch (socketAddress->sa.sa_family) {
            case AF_INET: {
                const char* address = inet_ntop(socketAddress->sa.sa_family,
                                                &(socketAddress->ipv4.sin_addr),
                                                addressBuffer,
                                                sizeof(addressBuffer));
                return [NSString stringWithFormat:@"http://%s:%d", address, (long) nonsense.port];
            }
            case AF_INET6: {
                const char* address = inet_ntop(socketAddress->sa.sa_family,
                                                &(socketAddress->ipv6.sin6_addr),
                                                addressBuffer,
                                                sizeof(addressBuffer));
                return [NSString stringWithFormat:@"http://%s:%d", address, (long) nonsense.port];
            }
            default: {
                return nonsense.hostName;
            }
        }
    } else {
        return nonsense.hostName;
    }
}

#pragma mark - Service Discovery Delegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser*)browser {
    DDLogDebug(@"Beginning nonsense search");
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)browser
             didNotSearch:(NSDictionary<NSString *,NSNumber *>*)errorDict {
    DDLogError(@"Could not perform nonsense discovery %@", errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)browser
           didFindService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    if ([service.name containsString:ServiceName]) {
        DDLogDebug(@"Discovered nonsense instance %@", service);
        
        [self.discovering addObject:service];
        service.delegate = self;
        [service resolveWithTimeout:ResolveTimeout];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser*)browser
         didRemoveService:(NSNetService*)service
               moreComing:(BOOL)moreComing {
    if ([service.name containsString:ServiceName]) {
        [self.delegate nonsenseScanService:self hostDisappeared:service];
    }
}

#pragma mark -

- (void)netServiceDidResolveAddress:(NSNetService*)service {
    DDLogDebug(@"Resolved nonsense instance %@", service);
    
    service.delegate = nil;
    [self.discovering removeObject:service];
    
    [self.delegate nonsenseScanService:self detectedHost:service];
}

- (void)netService:(NSNetService*)service
     didNotResolve:(NSDictionary<NSString*, NSNumber*>*)errorDict {
    DDLogError(@"Could not resolve nonsense instance %@", errorDict);
    
    service.delegate = nil;
    [self.discovering removeObject:service];
}

@end
