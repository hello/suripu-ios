//
//  HEMFormViewController.h
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMFormViewController;

@protocol HEMFormViewControllerDelegate <NSObject>

- (NSUInteger)numberOfFieldsIn:(HEMFormViewController*)formViewController;
- (NSString*)placeHolderTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;
- (NSString*)defaultTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;
- (void)saveFormContent:(NSArray*)content

@end

@interface HEMFormViewController : UIViewController

@end
