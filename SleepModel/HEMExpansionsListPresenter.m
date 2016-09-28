//
//  HEMExpansionsListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "HEMExpansionsListPresenter.h"
#import "HEMExpansionService.h"
#import "HEMMainStoryboard.h"
#import "HEMBasicTableViewCell.h"
#import "HEMURLImageView.h"
#import "HEMStyle.h"

@interface HEMExpansionsListPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;

@end

@implementation HEMExpansionsListPresenter

- (instancetype)initWithExpansionService:(HEMExpansionService*)service {
    if (self = [super init]) {
        _expansionService = service;
        _expansions = [service expansions]; // if some were cached
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    [self setTableView:tableView];
}

- (NSString*)localizedTextFromState:(SENExpansionState)state {
    switch (state) {
        case SENExpansionStateNotConfigured:
            return NSLocalizedString(@"expansion.state.not-configured", nil);
        case SENExpansionStateRevoked:
            return NSLocalizedString(@"expansion.state.revoked", nil);
        case SENExpansionStateConnectedOn:
            return NSLocalizedString(@"expansion.state.connected-on", nil);
        case SENExpansionStateConnectedOff:
            return NSLocalizedString(@"expansion.state.connected-off", nil);
        case SENExpansionStateUnknown:
        case SENExpansionStateNotConnected:
        default:
            return NSLocalizedString(@"expansion.state.not-connected", nil);
    }
}

- (void)refresh {
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getListOfExpansion:^(NSArray<SENExpansion *> * expansions, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (expansions) {
            [strongSelf setExpansions:expansions];
        } else if (error) {
            // TODO: handle it!
        }
        [[strongSelf tableView] reloadData];
    }];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self expansions] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard expansionReuseIdentifier];
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    SENExpansion* expansion = [self expansions][[indexPath row]];
    HEMBasicTableViewCell* basicCell = (id) cell;
    
    [[basicCell textLabel] setText:[expansion deviceName]];
    [[basicCell textLabel] setFont:[UIFont body]];
    [[basicCell textLabel] setTextColor:[UIColor grey6]];
    
    [[basicCell detailTextLabel] setTextColor:[UIColor grey3]];
    [[basicCell detailTextLabel] setFont:[UIFont body]];
    [[basicCell detailTextLabel] setText:[self localizedTextFromState:[expansion state]]];
    
    [[basicCell remoteImageView] setImageWithURL:[expansion iconUri]];
}

@end
