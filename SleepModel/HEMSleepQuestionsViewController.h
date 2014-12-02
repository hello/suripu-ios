//
//  HEMSleepQuestionsViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMSleepQuestionsDataSource;

@interface HEMSleepQuestionsViewController : HEMBaseController

@property (nonatomic, strong) UIImage* bgImage;
@property (nonatomic, strong) HEMSleepQuestionsDataSource* dataSource;

@end
