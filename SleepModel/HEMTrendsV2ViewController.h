//
//  HEMTrendsV2ViewController.h
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMTrendsGraphsPresenter;

@interface HEMTrendsV2ViewController : HEMBaseController

@property (nonatomic, strong) HEMTrendsGraphsPresenter* presenter;

@end
