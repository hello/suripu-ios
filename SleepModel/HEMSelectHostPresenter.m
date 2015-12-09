//
//  HEMSelectHostDataSource.m
//  Sense
//
//  Created by Kevin MacWhinnie on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMSelectHostPresenter.h"
#import "HEMNonsenseScanService.h"

NS_ENUM(NSUInteger) {
    SectionApiHosts = 0,
    SectionNonsenseHosts,
    SectionCount
};

static NSString* const HostCellIdentifier = @"HostCellIdentifier";

#pragma mark -

@interface HEMSelectHostPresenter () <UITableViewDataSource, UITableViewDelegate, HEMNonsenseScanServiceDelegate>

@property (nonatomic, weak) HEMNonsenseScanService* service;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, copy) HEMSelectHostPresenterDone doneAction;

#pragma mark -

@property (nonatomic) NSArray<NSString*>* apiHosts;
@property (nonatomic) NSMutableArray<NSNetService*>* nonsenseHosts;

@end

@implementation HEMSelectHostPresenter

- (instancetype)initWithService:(HEMNonsenseScanService*)service
{
    self = [super init];
    if (self) {
        self.service = service;
        self.service.delegate = self;
        
        self.apiHosts = @[@"https://dev-api.hello.is",
                          @"https://canary-api.hello.is",
                          @"https://api.hello.is"];
        self.nonsenseHosts = [NSMutableArray array];
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

- (void)nonsenseScanService:(HEMNonsenseScanService*)scanService
               detectedHost:(NSNetService*)nonsense {
    [self.nonsenseHosts addObject:nonsense];
    [self.tableView reloadData];
}

- (void)nonsenseScanService:(HEMNonsenseScanService*)scanService
            hostDisappeared:(NSNetService*)nonsense {
    [self.nonsenseHosts removeObject:nonsense];
    [self.tableView reloadData];
}

- (nullable NSString*)hostAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case SectionApiHosts: {
            return self.apiHosts[indexPath.row];
        }
        case SectionNonsenseHosts: {
            NSNetService* nonsense = self.nonsenseHosts[indexPath.row];
            return [self.service addressForNonsense:nonsense];
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
        case SectionApiHosts:
            return self.apiHosts.count;
            
        case SectionNonsenseHosts:
            return self.nonsenseHosts.count;
            
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
        case SectionApiHosts:
            return NSLocalizedString(@"debug.host.section.api", nil);
            
        case SectionNonsenseHosts:
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
        case SectionApiHosts:
            cell.textLabel.text = [self hostAtIndexPath:indexPath];
            cell.detailTextLabel.text = nil;
            break;
            
        case SectionNonsenseHosts:
            cell.textLabel.text = self.nonsenseHosts[indexPath.row].name;
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
