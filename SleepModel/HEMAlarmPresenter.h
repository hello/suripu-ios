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
@class HEMDeviceService;

typedef NS_ENUM(NSUInteger, HEMAlarmRowType) {
    HEMAlarmRowTypeSmart = 1,
    HEMAlarmRowTypeTone,
    HEMAlarmRowTypeRepeat,
    HEMAlarmRowTypeDelete,
    HEMAlarmRowTypeLight
};

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
- (void)didSelectRowType:(HEMAlarmRowType)rowType;

@end

@interface HEMAlarmPresenter : HEMPresenter

@property (nonatomic, strong, readonly) HEMAlarmCache* cache;
@property (nonatomic, weak, readonly) SENAlarm* alarm;
@property (nonatomic, weak, nullable) id<HEMAlarmPresenterDelegate> delegate;
@property (nonatomic, copy) NSString* successText;
@property (nonatomic, assign) CGFloat successDuration;

- (instancetype)initWithAlarm:(SENAlarm*)alarm
                 alarmService:(HEMAlarmService*)alarmService
                deviceService:(HEMDeviceService*)deviceService NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (void)bindWithTableView:(UITableView*)tableView;
- (void)bindWithTutorialPresentingController:(UIViewController*)controller;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;

@end

NS_ASSUME_NONNULL_END