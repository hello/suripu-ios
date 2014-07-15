//
//  HEMInsetGlyphTableViewCell.m
//  SleepModel
//
//  Created by Delisa Mason on 7/1/14.
//  Copyright (c) 2014 Delisa Mason. All rights reserved.
//

#import "HEMInsetGlyphTableViewCell.h"

static CGFloat const insetDistance = 30.f;

@interface HEMInsetGlyphTableViewCell ()
@property (nonatomic, strong) UIView* separatorView;
@end

@implementation HEMInsetGlyphTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.separatorView) {
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(insetDistance, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) - insetDistance, 1.f)];
        self.separatorView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.5f];
        [self addSubview:self.separatorView];
    }
}

@end
