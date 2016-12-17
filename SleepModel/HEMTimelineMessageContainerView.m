//
//  HEMTimelineMessageContainerView.m
//  Sense
//
//  Created by Delisa Mason on 6/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineMessageContainerView.h"

@implementation HEMTimelineMessageContainerView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self messageLabel] setHighlightedTextColor:[UIColor blackColor]];
    [[self summaryLabel] setHighlightedTextColor:[UIColor blackColor]];
    
    UIImage* chevronImage = [[self chevron] image];
    UIImage* highlightedImage = [chevronImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [[self chevron] setHighlightedImage:highlightedImage];
    [[self chevron] setTintColor:[UIColor blackColor]];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [[self messageLabel] setHighlighted:highlighted];
    [[self summaryLabel] setHighlighted:highlighted];
    [[self chevron] setHighlighted:highlighted];
}

@end
