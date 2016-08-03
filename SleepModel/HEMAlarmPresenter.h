//
//  HEMAlarmPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/30/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMAlarmService;
@class SENAlarm;
@class HEMAlarmPresenter;
@class HEMAlarmCache;
@class HEMClockPickerView;

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMAlarmAction)(void);

@protocol HEMAlarmPresenterDelegate <NSObject>

- (void)showConfirmationDialogWithTitle:(NSString*)title
                                message:(NSString*)message
                                 action:(HEMAlarmAction)action
                                   from:(HEMAlarmPresenter*)presenter;

- (void)showErrorWithTitle:(NSString*)title
                   message:(NSString*)message
                      from:(HEMAlarmPresenter*)presenter;

- (void)didSave:(BOOL)save from:(HEMAlarmPresenter*)presenter;
- (UIView*)activityContainerFor:(HEMAlarmPresenter*)presenter;

@end

@interface HEMAlarmPresenter : HEMPresenter

@property (nonatomic, strong, readonly) HEMAlarmCache* cache;
@property (nonatomic, weak, readonly) SENAlarm* alarm;
@property (nonatomic, weak, nullable) id<HEMAlarmPresenterDelegate> delegate;
@property (nonatomic, copy) NSString* successText;

- (instancetype)initWithAlarm:(nullable SENAlarm*)alarm
                 alarmService:(HEMAlarmService*)alarmService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)bindWithTableView:(UITableView*)tableView heightConstraint:(NSLayoutConstraint*)heightConstraint;
- (void)bindWithTutorialPresentingController:(UIViewController*)controller;
- (void)bindWithButtonContainer:(UIView*)container
                   cancelButton:(UIButton*)cancelButton
                     saveButton:(UIButton*)saveButton;
- (void)bindWithClockPickerView:(HEMClockPickerView*)clockPicker;

@end

NS_ASSUME_NONNULL_END