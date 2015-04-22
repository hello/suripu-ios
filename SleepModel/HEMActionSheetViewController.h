//
//  HEMAlertUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActionSheetViewController : UIViewController

/**
 * @property title
 *
 * @discussion
 * Optional text to be displayed above all the options that are added when the
 * controller is presented.
 */
@property (nonatomic, copy) NSString* title;

/**
 * @method addOptionWithTitle:description:block
 *
 * @param optionTitle: title to be displayed for the option
 * @param color:       optional color to be used for the title
 * @param description: optional description to be displayed below the title
 * @param block:       block to be invoked when the option is selected
 */
- (void)addOptionWithTitle:(NSString*)optionTitle
                titleColor:(UIColor*)color
               description:(NSString*)description
                     block:(void(^)(void))block;

@end
