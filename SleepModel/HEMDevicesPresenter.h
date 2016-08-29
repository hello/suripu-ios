//
//  HEMDevicesPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 12/29/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class HEMDevicesPresenter;
@class HEMDeviceService;

@protocol HEMDevicesPresenterDelegate <NSObject>

- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
                      from:(HEMDevicesPresenter*)presenter;
- (void)openSupportURL:(NSString*)url from:(HEMDevicesPresenter*)presenter;
- (void)pairSenseFrom:(HEMDevicesPresenter*)presenter;
- (void)showSenseSettingsFrom:(HEMDevicesPresenter*)presenter;
- (void)showPillSettingsFrom:(HEMDevicesPresenter*)presenter;
- (void)pairPillFrom:(HEMDevicesPresenter*)presenter;
- (void)showFirmwareUpdateFrom:(HEMDevicesPresenter*)presenter;
- (void)showModalController:(UIViewController*)controller from:(HEMDevicesPresenter*)presenter;

@end

@interface HEMDevicesPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMDevicesPresenterDelegate> delegate;
@property (nonatomic, assign, getter=isWaitingForFactoryResetToFinish) BOOL waitingForFactoryReset;

- (instancetype)initWithDeviceService:(HEMDeviceService*)deviceService;
- (void)bindWithCollectionView:(UICollectionView*)collectionView;
- (void)refresh;

@end

NS_ASSUME_NONNULL_END