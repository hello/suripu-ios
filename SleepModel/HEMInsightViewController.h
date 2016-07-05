//
//  HEMInsightViewController.h
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class SENInsight;
@class HEMInsightsService;

@interface HEMInsightViewController : HEMBaseController

@property (nonatomic, strong) SENInsight* insight;
@property (nonatomic, strong) UIColor* imageColor;
@property (nonatomic, strong) HEMInsightsService* insightService;

@end
