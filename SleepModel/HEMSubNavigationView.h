//
//  HEMSubNavigationView.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMSubNavigationView : UIView

@property (nonatomic, assign) NSInteger selectedControlTag;

- (void)addControl:(UIControl*)control;
- (BOOL)hasControls;

@end

NS_ASSUME_NONNULL_END