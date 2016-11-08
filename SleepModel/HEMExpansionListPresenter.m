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
static NSInteger const kHEMExpansionListCellMaskTag = 10;
static CGFloat const kHEMExpansionListCellMaskAlpha = 0.7f;

@interface HEMExpansionListPresenter() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) HEMActivityIndicatorView* activityView;
@property (nonatomic, weak) HEMExpansionService* expansionService;
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) NSArray<SENExpansion*>* expansions;
@property (nonatomic, strong) NSError* loadError;

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
        case SENExpansionStateConnectedOn:
            return NSLocalizedString(@"expansion.state.connected-on", nil);
        case SENExpansionStateConnectedOff:
            return NSLocalizedString(@"expansion.state.connected-off", nil);
        case SENExpansionStateRevoked:
            return NSLocalizedString(@"expansion.state.revoked", nil);
        case SENExpansionStateNotAvailable:
            return NSLocalizedString(@"expansion.state.not-available", nil);
        case SENExpansionStateUnknown:
        case SENExpansionStateNotConnected:
        default:
            return NSLocalizedString(@"expansion.state.not-connected", nil);
    }
}

- (void)refresh {
    [self setLoadError:nil];
    
    if ([[self expansions] count] == 0) {
        [[self activityView] start];
        [[self activityView] setHidden:NO];
    }
    
    __weak typeof(self) weakSelf = self;
    [[self expansionService] getListOfExpansion:^(NSArray<SENExpansion *> * expansions, NSError * error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setLoadError:error];
        if (expansions) {
            [strongSelf setExpansions:expansions];
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
    return [self loadError] ? 1 : [[self expansions] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* reuseId = [HEMMainStoryboard expansionReuseIdentifier];
    if ([self loadError]) {
        reuseId = [HEMMainStoryboard errorReuseIdentifier];
    }
    return [tableView dequeueReusableCellWithIdentifier:reuseId];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self loadError]) {
        [[cell textLabel] setText:NSLocalizedString(@"expansion.error.empty-list", nil)];
        [[cell textLabel] setFont:[UIFont errorStateDescriptionFont]];
        [[cell textLabel] setTextColor:[UIColor grey4]];
        [[cell textLabel] setNumberOfLines:0];
        [cell sizeToFit];
    } else {
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
        
        UIView* maskView = [basicCell viewWithTag:kHEMExpansionListCellMaskTag];
        if ([expansion state] == SENExpansionStateNotAvailable) {
            if (!maskView) {
                maskView = [[UIView alloc] initWithFrame:[basicCell bounds]];
                [maskView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:kHEMExpansionListCellMaskAlpha]];
                [maskView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [maskView setTag:kHEMExpansionListCellMaskTag];
            }
            [basicCell addSubview:maskView];
            [basicCell setUserInteractionEnabled:NO];
        } else {
            [maskView removeFromSuperview];
            [basicCell setUserInteractionEnabled:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    if (row < [[self expansions] count] && ![self loadError]) {
        SENExpansion* expansion = [self expansions][[indexPath row]];
        [[self actionDelegate] shouldShowExpansion:expansion fromPresenter:self];
    }
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
