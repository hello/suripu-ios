//
//  HEMAlarmTableViewCell.h
//  Sense
//
//  Created by Delisa Mason on 12/19/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMAlarmTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UISwitch* smartSwitch;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* detailLabel;
@end
