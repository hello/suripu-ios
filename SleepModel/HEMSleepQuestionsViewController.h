//
//  HEMSleepQuestionsViewController.h
//  Sense
//
//  Created by Jimmy Lu on 9/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMSleepQuestionsViewController : UIViewController

/**
 * @property
 * An array of SENQuestion objects to be asked
 */
@property (nonatomic, copy)   NSArray* questions;

@property (nonatomic, strong) UIImage* bgImage;

@end