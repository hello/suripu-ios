//
//  HEMSensorGraphCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <BEMSimpleLineGraph/BEMSimpleLineGraphView.h>
#import "HEMSensorGraphCollectionViewCell.h"

@implementation HEMSensorGraphCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureGraphView];
}

- (void)configureGraphView
{
    self.graphView.userInteractionEnabled = NO;
    self.graphView.enableBezierCurve = YES;
    self.graphView.enableReferenceXAxisLines = NO;
    self.graphView.enableReferenceYAxisLines = NO;
    self.graphView.enableXAxisLabel = NO;
    self.graphView.enableYAxisLabel = NO;
}

@end
