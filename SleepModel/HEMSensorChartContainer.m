//
//  HEMSensorChartContainer
//  Sense
//
//  Created by Jimmy Lu on 9/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorChartContainer.h"
#import "HEMStyle.h"

@interface HEMSensorChartContainer()

@property (nonatomic, weak) ChartViewBase* chartView;

@end

@implementation HEMSensorChartContainer

- (void)awakeFromNib {
    [[self topLimitLabel] setTextColor:[UIColor grey4]];
    [[self botLimitLabel] setTextColor:[UIColor grey4]];
    [[self topLimitLine] setBackgroundColor:[[UIColor grey3] colorWithAlphaComponent:0.2f]];
    [[self botLimitLine] setBackgroundColor:[[UIColor grey3] colorWithAlphaComponent:0.2f]];
}

- (void)setChartView:(ChartViewBase*)chartView {
    [self insertSubview:chartView atIndex:0];
    _chartView = chartView;
}

@end
