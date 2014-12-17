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
@class SENSensor;

@interface HEMSensorGraphCollectionViewCell : HEMCardCollectionViewCell
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *sensorMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

/**
 *  Sets attributed message text based on markdown attributes in the
 *  text string
 *
 *  @param markupMessageText text to apply
 */
- (void)setMessageText:(NSString *)markupMessageText;

- (void)setGraphData:(NSArray *)graphData sensor:(SENSensor *)sensor;
@end
