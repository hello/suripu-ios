//
//  HEMSensorChartContainer
//  Sense
//
//  Created by Jimmy Lu on 9/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorChartContainer.h"
#import "HEMStyle.h"

@implementation HEMSensorChartContainer

- (void)awakeFromNib {
    [[self topLimitLabel] setTextColor:[UIColor grey4]];
    [[self botLimitLabel] setTextColor:[UIColor grey4]];
    [[self topLimitLine] setBackgroundColor:[[UIColor grey3] colorWithAlphaComponent:0.2f]];
    [[self botLimitLine] setBackgroundColor:[[UIColor grey3] colorWithAlphaComponent:0.2f]];
}

- (void)setChartView:(UIView*)chartView {
    [self insertSubview:chartView atIndex:0];
}

@end
