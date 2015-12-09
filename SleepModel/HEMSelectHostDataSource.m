//
//  HEMSelectHostDataSource.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSelectHostDataSource.h"
#import <sys/socket.h>
#import <arpa/inet.h>

NS_ENUM(NSUInteger) {
    SectionStaticHosts = 0,
    SectionDiscoveredHosts,
    SectionCount
};

typedef union {
    struct sockaddr sa;
    struct sockaddr_in ipv4;
    struct sockaddr_in6 ipv6;
} ip_socket_address;

static NSString* ResolveHostAddress(NSNetService* _Nonnull service) {
    const ip_socket_address *socketAddress = service.addresses.firstObject.bytes;
    if (socketAddress) {
        char addressBuffer[INET6_ADDRSTRLEN];
        switch (socketAddress->sa.sa_family) {
            case AF_INET: {
                const char *address = inet_ntop(socketAddress->sa.sa_family,
                                                &(socketAddress->ipv4.sin_addr),
                                                addressBuffer,
                                                sizeof(addressBuffer));
                return [NSString stringWithFormat:@"http://%s:%d", address, (long) service.port];
            }
            case AF_INET6: {
                const char *address = inet_ntop(socketAddress->sa.sa_family,
                                                &(socketAddress->ipv6.sin6_addr),
                                                addressBuffer,
                                                sizeof(addressBuffer));
                return [NSString stringWithFormat:@"http://%s:%d", address, (long) service.port];
            }
            default: {
                return service.hostName;
            }
        }
    } else {
        return service.hostName;
    }
}

static NSString* const HostCellIdentifier = @"HostCellIdentifier";

#pragma mark -

@interface HEMSelectHostDataSource ()

@property (nonatomic) NSArray<NSString*>* staticHosts;
@property (nonatomic) NSMutableArray<NSNetService*>* discoveredHosts;

@end

@implementation HEMSelectHostDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.staticHosts = @[@"https://dev-api.hello.is",
                         @"https://canary-api.hello.is",
                         @"https://api.hello.is"];
        self.discoveredHosts = [NSMutableArray new];
    }
    return self;
}

#pragma mark -

- (void)addDiscoveredHost:(NSNetService*)host {
    [self.discoveredHosts addObject:host];
}

- (void)removeDiscoveredHost:(NSNetService*)host {
    [self.discoveredHosts removeObject:host];
}

- (nullable NSString*)hostAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionStaticHosts: {
            return self.staticHosts[indexPath.row];
        }
        case SectionDiscoveredHosts: {
            NSNetService* service = self.discoveredHosts[indexPath.row];
            return ResolveHostAddress(service);
        }
        default: {
            return nil;
        }
    }
}

- (void)displayCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case SectionStaticHosts:
            cell.textLabel.text = [self hostAtIndexPath:indexPath];
            cell.detailTextLabel.text = nil;
            break;
            
        case SectionDiscoveredHosts:
            cell.textLabel.text = self.discoveredHosts[indexPath.row].name;
            cell.detailTextLabel.text = [self hostAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
}

#pragma mark - Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return SectionCount;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionStaticHosts:
            return self.staticHosts.count;
            
        case SectionDiscoveredHosts:
            return self.discoveredHosts.count;
            
        default:
            DDLogError(@"Unknown section %d", (long)section);
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HostCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:HostCellIdentifier];
    }
    return cell;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SectionStaticHosts:
            return NSLocalizedString(@"debug.host.section.api", nil);
            
        case SectionDiscoveredHosts:
            return NSLocalizedString(@"debug.host.section.nonsense", nil);
            
        default:
            return nil;
    }
}

@end
