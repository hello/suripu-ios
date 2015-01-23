//
//  HEMSettingsTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/5/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSettingsCellTableMargin;

@interface HEMSettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;
@property (weak, nonatomic) IBOutlet UIView*  accessory;

- (void)showTopCorners;
- (void)showBottomCorners;
- (void)showNoCorners;
- (void)showTopAndBottomCorners;

@end
