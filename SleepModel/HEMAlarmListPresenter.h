//
//  HEMAlarmListPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 6/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMAlarmService;
@class HEMSubNavigationView;
@class HEMAlarmListPresenter;
@class HEMAlarmAddButton;
@class HEMActivityIndicatorView;
@class HEMExpansionService;

@protocol HEMAlarmListPresenterDelegate <NSObject>

- (void)didSelectAlarm:(SENAlarm*)alarm fromPresenter:(HEMAlarmListPresenter*)presenter;
- (void)addNewAlarmFromPresenter:(HEMAlarmListPresenter*)presenter;
- (void)showErrorWithTitle:(NSString*)title
                   message:(NSString*)message
             fromPresenter:(HEMAlarmListPresenter*)presenter;

@optional
- (void)didFinishLoadingDataFrom:(HEMAlarmListPresenter*)presenter;

@end

@interface HEMAlarmListPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMAlarmListPresenterDelegate> delegate;
@property (nonatomic, assign, getter=isLoading, readonly) BOOL loading;

- (instancetype)initWithAlarmService:(HEMAlarmService*)alarmService
                    expansionService:(HEMExpansionService*)expansionService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)bindWithSubNavigationView:(HEMSubNavigationView*)subNav;
- (void)bindWithAddButton:(HEMAlarmAddButton*)addButton
     withBottomConstraint:(NSLayoutConstraint*)bottomConstraint;
- (void)bindWithDataLoadingIndicator:(HEMActivityIndicatorView*)dataLoadingIndicator;
- (void)update;

@end
