//
//  HEMTodayVIewCell.h
//  Sense
//
//  Created by Delisa Mason on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSensorExtTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sensorIconView;
@property (weak, nonatomic) IBOutlet UILabel *sensorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorValueLabel;

@end
