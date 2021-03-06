//
//  HEMSensorChartCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMSensorChartContainer;

@interface HEMSensorChartCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet HEMSensorChartContainer *chartContentView;
@property (weak, nonatomic) IBOutlet UIView *xAxisLabelContainer;

- (void)setXAxisLabels:(NSArray<NSString*>*)labels;
- (void)applyStyle;

@end
