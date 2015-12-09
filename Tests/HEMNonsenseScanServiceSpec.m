//
//  HEMNonsenseScanServiceSpec.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/9/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <arpa/inet.h>
#import "HEMNonsenseScanService.h"

SPEC_BEGIN(HEMNonsenseScanServiceSpec)

describe(@"-addressForNonsense:", ^{
    __block HEMNonsenseScanService* service;
    __block NSNetService* nonsense;
    
    beforeAll(^{
        service = [HEMNonsenseScanService new];
        nonsense = [[NSNetService alloc] initWithDomain:@""
                                                   type:@"_http._tcp."
                                                   name:@"nonsense-service"
                                                   port:3000];
        [nonsense stub:@selector(hostName) andReturn:@"Snazzy MacBook Pro"];
    });
    
    it(@"should return the host", ^{
        [nonsense stub:@selector(addresses) andReturn:@[]];
        
        NSString* address = [service addressForNonsense:nonsense];
        [[address should] equal:@"Snazzy MacBook Pro"];
    });
    
    it(@"should return the IPv4 address", ^{
        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = 3000;
        inet_pton(AF_INET, "192.168.0.22", &(addr.sin_addr));
        
        NSData* rawAddress = [NSData dataWithBytes:&addr length:sizeof(addr)];
        [nonsense stub:@selector(addresses) andReturn:@[rawAddress]];
        
        NSString* address = [service addressForNonsense:nonsense];
        [[address should] equal:@"http://192.168.0.22:3000"];
    });
    
    it(@"should return the IPv6 address", ^{
        struct sockaddr_in6 addr;
        addr.sin6_family = AF_INET6;
        addr.sin6_port = 3000;
        inet_pton(AF_INET6, "fe80:0000:0000:0000:0202:b3ff:fe1e:8329", &(addr.sin6_addr));
        
        NSData* rawAddress = [NSData dataWithBytes:&addr length:sizeof(addr)];
        [nonsense stub:@selector(addresses) andReturn:@[rawAddress]];
        
        NSString* address = [service addressForNonsense:nonsense];
        [[address should] equal:@"http://fe80::202:b3ff:fe1e:8329:3000"];
    });
});

describe(@"discovery", ^{
    __block NSNetServiceBrowser* browser;
    __block HEMNonsenseScanService* service;
    __block id delegate;
    
    beforeEach(^{
        browser = [NSNetServiceBrowser new];
        service = [HEMNonsenseScanService new];
        delegate = [KWMock mockForProtocol:@protocol(HEMNonsenseScanServiceDelegate)];
        service.delegate = delegate;
    });
    
    it(@"should ignore untargeted services", ^{
        NSNetService* notNonsense = [[NSNetService alloc] initWithDomain:@""
                                                                    type:@".udp."
                                                                    name:@"some other thing"
                                                                    port:9000];
        
        [[delegate shouldNotEventually] receive:@selector(nonsenseScanService:detectedHost:)
                                  withArguments:service, notNonsense];
        
        [[delegate shouldNotEventually] receive:@selector(nonsenseScanService:hostDisappeared:)
                                  withArguments:service, notNonsense];
        
        [service netServiceBrowser:browser didFindService:notNonsense moreComing:YES];
        [service netServiceBrowser:browser didRemoveService:notNonsense moreComing:YES];
    });
    
    it(@"should resolve targeted services", ^{
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:8000];
        [nonsense stub:@selector(resolveWithTimeout:)];
        
        [[delegate shouldEventually] receive:@selector(nonsenseScanService:detectedHost:)
                               withArguments:service, nonsense];
        
        [service netServiceBrowser:browser didFindService:nonsense moreComing:YES];
        [[(id)nonsense.delegate should] equal:service];
        [service netServiceDidResolveAddress:nonsense];
        [[(id)nonsense.delegate should] beNil];
    });
    
    it(@"should report disappearance of target services", ^{
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:8000];
        
        [[delegate shouldEventually] receive:@selector(nonsenseScanService:hostDisappeared:)
                               withArguments:service, nonsense];
        
        [service netServiceBrowser:browser didRemoveService:nonsense moreComing:YES];
    });
    
    it(@"should stop pending resolutions", ^{
        NSNetService* nonsense = [[NSNetService alloc] initWithDomain:@""
                                                                 type:@"_http._tcp."
                                                                 name:@"nonsense-server"
                                                                 port:8000];
        [nonsense stub:@selector(resolveWithTimeout:)];
        [nonsense stub:@selector(stop)];
        
        [service netServiceBrowser:browser didFindService:nonsense moreComing:YES];
        [[(id)nonsense.delegate should] equal:service];
        [[nonsense shouldEventually] receive:@selector(stop)];
        [service stop];
        [[(id)nonsense.delegate should] beNil];
    });
});

SPEC_END
