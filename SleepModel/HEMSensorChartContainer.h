//
//  HEMSensorChartContainer.h
//  Sense
//
//  Created by Jimmy Lu on 9/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>
#import <UIKit/UIKit.h>

@interface HEMSensorChartContainer : UIView

@property (weak, nonatomic) IBOutlet UILabel* topLimitLabel;
@property (weak, nonatomic) IBOutlet UIView* topLimitLine;

@property (weak, nonatomic) IBOutlet UILabel* botLimitLabel;
@property (weak, nonatomic) IBOutlet UIView* botLimitLine;

- (void)setChartView:(ChartViewBase*)chartView;
- (ChartViewBase*)chartView;

@end
