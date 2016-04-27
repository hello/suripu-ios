//
//  HEMListPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMListItemCell;
@class HEMActivityIndicatorView;

NS_ASSUME_NONNULL_BEGIN

@class HEMListPresenter;

@protocol HEMListPresenterDelegate <NSObject>

- (void)presentErrorWithTitle:(NSString*)title
                      message:(NSString*)message
                         from:(HEMListPresenter*)presenter;

@end

@protocol HEMListDelegate <NSObject>

- (void)didSelectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter*)presenter;

@optional
- (void)goBackFrom:(HEMListPresenter*)presenter;
- (void)didDeselectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter*)presenter;

@end

@interface HEMListPresenter : HEMPresenter <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<HEMListDelegate> delegate;
@property (nonatomic, weak) id<HEMListPresenterDelegate> presenterDelegate;

@property (nonatomic, weak, readonly) UITableView* tableView;
@property (nonatomic, weak, readonly, nullable) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, copy, readonly) NSString* title;
@property (nonatomic, copy, nullable) NSArray* selectedItemNames;
@property (nonatomic, copy, nullable) NSArray* items;
@property (nonatomic, assign) BOOL hideExtraNavigationBar; // defaults to YES

- (instancetype)initWithTitle:(NSString*)title
                        items:(nullable NSArray*)items
            selectedItemNames:(nullable NSArray*)selectedItemNames;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicatorView;

- (void)bindWithNavigationBar:(UINavigationBar*)navigationBar
            withTopConstraint:(NSLayoutConstraint*)topConstraint;

/**
 * @discussion
 * This should not be called directly, except by sub classes that require content
 * to be first asynchronously loaded before items can be displayed.  In such case,
 * this method should be called as soon as items are loaded in to cache
 */
- (void)preSelectItems;

/**
 * @discussion
 * Subclasses should implement this method.  By default, this does nothing and
 * it should be not be manually called
 *
 * @param cell: the list item cell to configure
 * @param item: the list item for the cell
 */
- (void)configureCell:(HEMListItemCell*)cell forItem:(id)item;

/**
 * @discussion
 * Subclasses should implement this method to update the cell with the selection
 * state, if something more is required than simply having the cell be selected
 *
 * @parm cell: the cell to update
 * @param item: the list item for the cell
 * @param selected: YES if selected, NO otherwise
 */
- (void)updateCell:(UITableViewCell*)cell withItem:(id)item selected:(BOOL)selected;

/**
 * @discussion
 * Subclasses should implement this method to determine the index of an item with
 * the given name
 *
 * @param name: the display name of the item
 * @return the index of the item that matches the provided name
 */
- (NSInteger)indexOfItemWithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END