//
//  HEMBarButtonItem.m
//  Sense
//
//  Created by Delisa Mason on 11/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTimelineTopButton.h"
#import "HelloStyleKit.h"

@implementation HEMTimelineTopButton

- (void)awakeFromNib {
    UIImage* image = self.imageView.image;
    [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self updateTintColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateTintColor];
}

- (void)updateTintColor {
    [self setTintColor:[self isEnabled] ? [HelloStyleKit barButtonEnabledColor] : [HelloStyleKit barButtonDisabledColor]];
}

@end
