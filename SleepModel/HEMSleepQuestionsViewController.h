//
//  HEMSleepQuestionsViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"
#import "HEMQuestionsDataSource.h"

@class HEMSleepQuestionsDataSource;

@interface HEMSleepQuestionsViewController : HEMBaseController

@property (nonatomic, strong) UIImage* bgImage;
@property (nonatomic, strong) id<HEMQuestionsDataSource> dataSource;

@end
