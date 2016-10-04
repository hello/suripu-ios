//
//  HEMExpansionPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMExpansionService;
@class HEMActionButton;
@class SENExpansion;
@class HEMExpansionPresenter;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMExpansionDelegate <NSObject>

- (void)showController:(UIViewController*)controller
      onRootController:(BOOL)root
         fromPresenter:(HEMExpansionPresenter*)presenter;

- (void)showEnableInfoDialogFromPresenter:(HEMExpansionPresenter*)presenter;

- (void)removedAccessFrom:(HEMExpansionPresenter*)presenter;

- (void)connectExpansionFromPresenter:(HEMExpansionPresenter*)presenter;

@end

@interface HEMExpansionPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMExpansionDelegate> delegate;

- (instancetype)initWithExpansionService:(HEMExpansionService*)service
                            forExpansion:(SENExpansion*)expansion;
- (void)bindWithTableView:(UITableView*)tableView;
- (void)bindWithConnectContainer:(UIView*)container
             andBottomConstraint:(NSLayoutConstraint*)bottomConstraint
                      withButton:(HEMActionButton*)connectButton;
- (void)bindWithNavBar:(UINavigationBar*)navBar;
- (void)bindWithRootView:(UIView*)view;
- (BOOL)hasNavBar;
- (void)reload:(SENExpansion*)expansion;

@end

NS_ASSUME_NONNULL_END