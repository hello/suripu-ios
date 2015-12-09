//
//  HEMSelectHostDataSource.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSelectHostPresenter.h"
#import <sys/socket.h>
#import <arpa/inet.h>
#import "HEMNonsenseScanService.h"

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

@interface HEMSelectHostPresenter () <UITableViewDataSource, UITableViewDelegate, HEMNonsenseScanServiceDelegate>

@property (nonatomic, weak) HEMNonsenseScanService* service;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, copy) HEMSelectHostPresenterDone doneAction;

#pragma mark -

@property (nonatomic) NSArray<NSString*>* staticHosts;
@property (nonatomic) NSMutableArray<NSNetService*>* discoveredHosts;

@end

@implementation HEMSelectHostPresenter

- (instancetype)initWithService:(HEMNonsenseScanService*)service
{
    self = [super init];
    if (self) {
        self.service = service;
        self.service.delegate = self;
        
        self.staticHosts = @[@"https://dev-api.hello.is",
                         @"https://canary-api.hello.is",
                         @"https://api.hello.is"];
        self.discoveredHosts = [NSMutableArray new];
    }
    return self;
}

- (void)willAppear {
    [self.service start];
}

- (void)willDisappear {
    [self.service stop];
}

- (void)bindTableView:(UITableView*)tableView whenDonePerform:(HEMSelectHostPresenterDone)doneAction {
    self.tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.doneAction = doneAction;
}

#pragma mark -

- (void)nonsenseScanService:(HEMNonsenseScanService *)scanService
               detectedHost:(NSNetService *)nonsense {
    [self.discoveredHosts addObject:nonsense];
    [self.tableView reloadData];
}

- (void)nonsenseScanService:(HEMNonsenseScanService *)scanService
            hostDisappeared:(NSNetService *)nonsense {
    [self.discoveredHosts removeObject:nonsense];
    [self.tableView reloadData];
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

#pragma mark - Table Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString* host = [self hostAtIndexPath:indexPath];
    self.doneAction(host);
}

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
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

#pragma mark - Dealloc

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

@end
