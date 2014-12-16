//
//  HEMSensorGraphCollectionViewCell.h
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

@class BEMSimpleLineGraphView;

@interface HEMSensorGraphCollectionViewCell : HEMCardCollectionViewCell
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@end
