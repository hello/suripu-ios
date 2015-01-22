//
//  HEMSettingsTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/5/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* valueLabel;

- (void)showTopCorners;
- (void)showBottomCorners;
- (void)showNoCorners;

@end
