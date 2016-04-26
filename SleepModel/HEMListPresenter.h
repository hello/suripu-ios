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

@protocol HEMListDelegate <NSObject>

- (void)didSelectItem:(id)item atIndex:(NSInteger)index from:(HEMListPresenter*)presenter;

@optional
- (void)goBackFrom:(HEMListPresenter*)presenter;

@end

@interface HEMListPresenter : HEMPresenter <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<HEMListDelegate> delegate;

@property (nonatomic, weak, readonly) UITableView* tableView;
@property (nonatomic, weak, readonly) HEMActivityIndicatorView* indicatorView;
@property (nonatomic, copy, readonly) NSString* title;
@property (nonatomic, copy, readonly) NSString* selectedItemName;
@property (nonatomic, copy, nullable) NSArray* items;
@property (nonatomic, assign) BOOL hideExtraNavigationBar; // defaults to YES

- (instancetype)initWithTitle:(NSString*)title
                        items:(NSArray*)items
             selectedItemName:(NSString*)selectedItemName;

- (void)bindWithTableView:(UITableView*)tableView;

- (void)bindWithActivityIndicator:(HEMActivityIndicatorView*)indicatorView;

- (void)bindWithNavigationBar:(UINavigationBar*)navigationBar
            withTopConstraint:(NSLayoutConstraint*)topConstraint;

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
 * Subclasses should implement this method.  By default, this does nothing and
 * it should be not be manually called
 *
 * @param cell: the list item cell
 * @Param selected: YES if cell should be selected. NO otherwise
 * @param item: the list item selected
 */
- (void)cell:(HEMListItemCell*)cell isSelected:(BOOL)selected forItem:(id)item;

@end

NS_ASSUME_NONNULL_END