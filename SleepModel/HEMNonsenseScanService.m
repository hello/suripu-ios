//
//  HEMNonsenseScanService.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMNonsenseScanService.h"

static NSString* const ServiceType = @"_http._tcp.";
static NSString* const ServiceName = @"nonsense-server";
static NSTimeInterval const ResolveTimeout = 5.0;

@interface HEMNonsenseScanService () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic) NSMutableArray<NSNetService*>* discovering;
@property (nonatomic) NSNetServiceBrowser* netServiceBrowser;

@end

@implementation HEMNonsenseScanService

- (instancetype)initWithDelegate:(id <HEMNonsenseScanServiceDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        
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
    
    for (NSNetService *service in self.discovering) {
        [service stop];
        service.delegate = nil;
    }
    [self.discovering removeAllObjects];
}

#pragma mark - Service Discovery Delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
             didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    DDLogError(@"Could not perform nonsense discovery %@", errorDict);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
           didFindService:(NSNetService *)service
               moreComing:(BOOL)moreComing {
    if ([service.name containsString:ServiceName]) {
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
