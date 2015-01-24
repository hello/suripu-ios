//
//  HEMChoiceViewController.h
//  Sense
//
//  Created by Jimmy Lu on 1/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMChoiceViewController;

@protocol HEMChoiceDelegate <NSObject>

- (void)didSelectChoiceAtIndex:(NSUInteger)index from:(HEMChoiceViewController*)controller;

@end

@interface HEMChoiceViewController : UIViewController

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, copy)   NSArray* choices;
@property (nonatomic, weak)   id<HEMChoiceDelegate> delegate;

@end
