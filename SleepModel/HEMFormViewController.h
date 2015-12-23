//
//  HEMFormViewController.h
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

@class HEMFormPresenter;

@interface HEMFormViewController : HEMBaseController

@property (nonatomic, strong) HEMFormPresenter* presenter;

@end
