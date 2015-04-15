//
//  HEMActivityIndicatorView.h
//  Sense
//
//  Created by Jimmy Lu on 11/26/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActivityIndicatorView : UIView

- (instancetype)initWithImage:(UIImage*)image andFrame:(CGRect)frame;
- (void)start;
- (void)stop;

@end
