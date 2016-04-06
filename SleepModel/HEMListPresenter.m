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

static CGFloat const HEMListPresenterSelectionDelay = 0.15f;

@interface HEMListPresenter()

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, copy) NSArray* items;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* selectedItemName;

@end

@implementation HEMListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName {
    self = [super init];
    if (self) {
        _title = [title copy];
        _items = [items copy];
        _selectedItemName = [selectedItemName copy];
    }
    return self;
}

- (void)bindWithTableView:(UITableView*)tableView {
    UIView* header = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    UIView* footer = [[HEMSettingsHeaderFooterView alloc] initWithTopBorder:NO bottomBorder:NO];
    
    [tableView setSeparatorColor:[UIColor separatorColor]];
    [tableView setTableHeaderView:header];
    [tableView setTableFooterView:footer];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [self setTableView:tableView];
}

- (void)configureCell:(HEMListItemCell*)cell forItem:(id)item {
    [[cell itemLabel] setFont:[UIFont listItemTitleFont]];
    [[cell itemLabel] setTextColor:[UIColor listItemTextColor]];
}

- (void)selectItemAtIndexPath:(NSIndexPath*)indexPathToSelect {
    for (NSIndexPath* indexPath in [[self tableView] indexPathsForVisibleRows]) {
        UITableViewCell* cell = [[self tableView] cellForRowAtIndexPath:indexPath];
        [cell setSelected:[indexPath isEqual:indexPathToSelect]];
        id item = [self items][[indexPath row]];
        [self cell:(id)cell isSelected:[cell isSelected] forItem:item];
    }
}

- (void)cell:(HEMListItemCell*)cell isSelected:(BOOL)selected forItem:(id)item {}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = [self items][[indexPath row]];
    [self configureCell:(id)cell forItem:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectItemAtIndexPath:indexPath];
    
    id item = [self items][[indexPath row]];
    NSInteger index = [indexPath row];
    
    [tableView setUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    int64_t secs = (int64_t)(HEMListPresenterSelectionDelay * NSEC_PER_SEC);
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, secs);
    dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
        [tableView setUserInteractionEnabled:YES];
        [[weakSelf delegate] didSelectItem:item atIndex:index from:weakSelf];
    });

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

@end
