//
//  HEMTutorialViewController.h
//  Sense
//
//  Created by Jimmy Lu on 6/8/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTutorialViewController : UIViewController

/**
 * @property tutorials
 * 
 * @discussion
 * An array of HEMTutorialContent objects that will define the screens / tutorials
 * shown.
 */
@property (nonatomic, strong) NSArray* tutorials;

@property (nonatomic, strong) UIImage* backgroundImage;

@end
