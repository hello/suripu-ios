//
//  HEMPresleepItemCollectionViewCell.h
//  Sense
//
//  Created by Delisa Mason on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SENSleepResultSensorInsight;

@protocol HEMPresleepActionDelegate <NSObject>

@optional

- (void)willShowDetailsForInsight:(SENSleepResultSensorInsight*)insight;
- (void)willHideInsightDetails;

@end

@interface HEMPresleepItemCollectionViewCell : UICollectionViewCell

- (void)addButtonsForInsights:(NSArray*)insights;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) id<HEMPresleepActionDelegate> presleepActionDelegate;
@end
