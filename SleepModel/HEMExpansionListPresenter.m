//
//  HEMExpansionsListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 9/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENExpansion.h>

#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "HEMExpansionListPresenter.h"
#import "HEMExpansionService.h"
#import "HEMMainStoryboard.h"
#import "HEMBasicTableViewCell.h"
#import "HEMURLImageView.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMActivityIndicatorView.h"
#import "HEMStyle.h"

static CGFloat const kHEMExpansionListImageBorder = 0.5f;
static CGFloat const kHEMExpansionListCellSize = 72.0f;
static CGFloat const kHEMExpansionListImageCornerRadius = 5.0f;

@interface HEMExpansionListPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMActivityIndicatorView* activityView;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;

@end

@implementation HEMExpansionListPresenter

- (instancetype)initWithExpansionService:(HEMExpansionService*)service {
    if (self = [super init]) {
        _expansionService = service;
        _expansions = [service expansions]; // if some were cached
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:footer];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self setTableView:tableView];
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)activityIndicator {
    [activityIndicator start];
    [activityIndicator setHidden:NO];
    [self setActivityView:activityIndicator];
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
    if ([[self expansions] count] == 0) {
        [[self activityView] start];
        [[self activityView] setHidden:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getListOfExpansion:^(NSArray<SENExpansion *> * expansions, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (expansions) {
            [strongSelf setExpansions:expansions];
        } else if (error) {
            // TODO: handle it!
        }
        [[strongSelf activityView] stop];
        [[strongSelf activityView] setHidden:YES];
        [[strongSelf tableView] reloadData];
    }];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self refresh];
}

#pragma mark - UITableViewDelegate / UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHEMExpansionListCellSize;
}

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
    NSInteger row = [indexPath row];
    BOOL lastRow = row == [[self expansions] count] - 1;
    SENExpansion* expansion = [self expansions][[indexPath row]];
    NSString* iconUri = [[expansion remoteIcon] uriForCurrentDevice];
    NSString* stateString = [self localizedTextFromState:[expansion state]];
    HEMBasicTableViewCell* basicCell = (id) cell;
    
    [[basicCell customTitleLabel] setText:[expansion deviceName]];
    [[basicCell customTitleLabel] setFont:[UIFont body]];
    [[basicCell customTitleLabel] setTextColor:[UIColor grey6]];
    
    [[basicCell customDetailLabel] setTextColor:[UIColor grey3]];
    [[basicCell customDetailLabel] setFont:[UIFont body]];
    [[basicCell customDetailLabel] setText:stateString];
    
    [[[basicCell remoteImageView] layer] setCornerRadius:kHEMExpansionListImageCornerRadius];
    [[[basicCell remoteImageView] layer] setBorderWidth:kHEMExpansionListImageBorder];
    [[[basicCell remoteImageView] layer] setBorderColor:[[UIColor grey2] CGColor]];
    [[basicCell remoteImageView] setClipsToBounds:YES];
    [[basicCell remoteImageView] setContentMode:UIViewContentModeScaleAspectFit];
    [[basicCell remoteImageView] setImageWithURL:iconUri];
    [[basicCell remoteImageView] setBackgroundColor:[UIColor grey3]];
    
    [basicCell showSeparator:!lastRow];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SENExpansion* expansion = [self expansions][[indexPath row]];
    [[self actionDelegate] shouldShowExpansion:expansion fromPresenter:self];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
