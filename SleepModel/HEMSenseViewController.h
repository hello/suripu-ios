//
//  HEMSenseViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/24/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMSenseViewController;

@protocol HEMSenseControllerDelegate <NSObject>

@optional
- (void)willUnpairSenseFrom:(HEMSenseViewController*)viewController;
- (void)didUnpairSenseFrom:(HEMSenseViewController*)viewController;
- (void)didUpdateWiFiFrom:(HEMSenseViewController*)viewController;
- (void)didFactoryRestoreFrom:(HEMSenseViewController*)viewController;
- (void)didDismissActivityFrom:(HEMSenseViewController*)viewController;
- (void)didEnterPairingModeFrom:(HEMSenseViewController*)viewController;

@end

@interface HEMSenseViewController : HEMBaseController

@property (nonatomic, weak) id<HEMSenseControllerDelegate> delegate;

@end
