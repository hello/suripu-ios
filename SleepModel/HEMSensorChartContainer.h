//
//  HEMSensorChartContainer.h
//  Sense
//
//  Created by Jimmy Lu on 9/8/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <Charts/Charts-Swift.h>
#import <UIKit/UIKit.h>

@class HEMSensorChartContainer;

@protocol HEMSensorChartScrubberDelegate <NSObject>

- (void)willBeginScrubbingIn:(HEMSensorChartContainer*)chartContainer;
- (void)didEndScrubbingIn:(HEMSensorChartContainer*)chartContainer;
- (void)didMoveScrubberTo:(CGPoint)pointInChartView
                   within:(HEMSensorChartContainer*)chartContainer;

@end

@interface HEMSensorChartContainer : UIView

@property (weak, nonatomic) IBOutlet UILabel* topLimitLabel;
@property (weak, nonatomic) IBOutlet UIView* topLimitLine;

@property (weak, nonatomic) IBOutlet UILabel* botLimitLabel;
@property (weak, nonatomic) IBOutlet UIView* botLimitLine;

@property (nonatomic, weak) id<HEMSensorChartScrubberDelegate> delegate;

- (void)setChartView:(ChartViewBase*)chartView;
- (ChartViewBase*)chartView;
- (void)setScrubberColor:(UIColor*)color;

@end
