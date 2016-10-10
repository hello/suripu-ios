//
//  HEMAlarmTableViewCell.h
//  Sense
//
//  Created by Delisa Mason on 12/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMActivityIndicatorView.h"

@interface HEMAlarmTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UISwitch* smartSwitch;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* detailLabel;
@property (nonatomic, weak) IBOutlet UIButton *infoButton;
@property (nonatomic, weak) IBOutlet HEMActivityIndicatorView* activityView;
@property (nonatomic, weak) IBOutlet UIImageView* errorIcon;

- (void)showActivity:(BOOL)show;

@end
