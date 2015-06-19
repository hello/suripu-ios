//
//  HEMHintMessageView.h
//  Sense
//
//  Created by Jimmy Lu on 6/18/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMHintMessageView : UIView

@property (nonatomic, strong, readonly) UIButton* dismissButton;

- (instancetype)initWithMessage:(NSString*)message constrainedToWidth:(CGFloat)width;

@end
