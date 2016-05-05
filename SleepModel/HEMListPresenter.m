//
//  HEMListPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListPresenter.h"
#import "HEMStyle.h"
#import "HEMSettingsHeaderFooterView.h"
#import "HEMMainStoryboard.h"
#import "HEMListItemCell.h"
#import "HEMNavigationShadowView.h"
#import "HEMActivityIndicatorView.h"

static CGFloat const HEMListPresenterSelectionDelay = 0.15f;

@interface HEMListPresenter()

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign, getter=isPreSelected) BOOL preSelected;

@end

@implementation HEMListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
            selectedItemNames:(NSArray*)selectedItemNames {
    self = [super init];
    if (self) {
        _hideExtraNavigationBar = YES;
        _title = [title copy];
        _items = [items copy];
        _selectedItemNames = [selectedItemNames copy];
    }
    return self;
}

- (void)bindWithNavigationBar:(UINavigationBar*)navigationBar
            withTopConstraint:(NSLayoutConstraint*)topConstraint {
    
    if ([self hideExtraNavigationBar]) {
        CGFloat height = CGRectGetHeight([navigationBar bounds]);
        [topConstraint setConstant:-height];
        [navigationBar setHidden:YES];
    } else {
        UINavigationItem* topItem = [navigationBar topItem];
        UIBarButtonItem* backButton = [topItem leftBarButtonItem];
        [backButton setTarget:self];
        [backButton setAction:@selector(back:)];
        
        HEMNavigationShadowView* shadowView =
            [[HEMNavigationShadowView alloc] initWithNavigationBar:navigationBar];
        [shadowView showSeparator:YES];
        [navigationBar addSubview:shadowView];
        [self bindWithShadowView:shadowView];
    }
}

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicatorView {
    [indicatorView setHidden:YES];
    [self setIndicatorView:indicatorView];
}

- (void)bindWithTableView:(UITableView*)tableView {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO
                                                               bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO
                                                               bottomBorder:NO];
    
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:footer];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    [self setTableView:tableView];
}

- (void)configureCell:(HEMListItemCell*)cell forItem:(id)item {
    [[cell itemLabel] setFont:[UIFont listItemTitleFont]];
    [[cell itemLabel] setTextColor:[UIColor textColor]];
}

- (NSInteger)indexOfItemWithName:(NSString*)name {
    return -1;
}

- (void)updateCell:(HEMListItemCell*)cell withItem:(id)item selected:(BOOL)selected {
    [cell setSelected:selected];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [self preSelectItems];
}

- (void)preSelectItems {
    if ([self isPreSelected]) {
        return;
    }
    
    BOOL hasSelectedItems = [[self selectedItemNames] count] > 0;
    BOOL withinRange = [[self selectedItemNames] count] <= [[self items] count];
    if (hasSelectedItems && withinRange) {
        for (NSString* itemName in [self selectedItemNames]) {
            NSInteger index = [self indexOfItemWithName:itemName];
            if (index >= 0) {
                NSIndexPath* path = [NSIndexPath indexPathForRow:index inSection:0];
                [[self tableView] selectRowAtIndexPath:path
                                              animated:NO
                                        scrollPosition:UITableViewScrollPositionNone];
            }
        }
        [self setPreSelected:YES];
    }
}

#pragma mark - Nav Item

- (void)back:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(goBackFrom:)]) {
        [[self delegate] goBackFrom:self];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self items][[indexPath row]];
    [self configureCell:(id)cell forItem:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self items][[indexPath row]];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[HEMListItemCell class]]) {
        HEMListItemCell* listCell = (id)cell;
        [listCell flashTouchIndicator];
    }
    
    [self updateCell:cell withItem:item selected:YES];
    
    if (![tableView allowsMultipleSelection]) {
        
        // add a delay to let delegate now selection has been made so dismissal
        // of the controller can be done
        [tableView setUserInteractionEnabled:NO];
        __weak typeof(self) weakSelf = self;
        int64_t secs = (int64_t)(HEMListPresenterSelectionDelay * NSEC_PER_SEC);
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, secs);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
            NSInteger index = [indexPath row];
            [tableView setUserInteractionEnabled:YES];
            [[weakSelf delegate] didSelectItem:item atIndex:index from:weakSelf];
        });
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self items][[indexPath row]];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    [self updateCell:cell withItem:item selected:NO];
    
    if ([[self delegate] respondsToSelector:@selector(didDeselectItem:atIndex:from:)]) {
        NSInteger index = [indexPath row];
        [[self delegate] didDeselectItem:item atIndex:index from:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self items] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEMSettingsHeaderFooterHeightWithTitle;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HEMSettingsHeaderFooterView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:YES];
    [header setTitle:[[self title] uppercaseString]];
    return header;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:YES bottomBorder:NO];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:[HEMMainStoryboard listItemReuseIdentifier]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_tableView) {
        [_tableView setDelegate:nil];
        [_tableView setDataSource:nil];
    }
}

@end
