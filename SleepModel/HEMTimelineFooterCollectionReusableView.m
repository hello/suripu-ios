//
//  HEMTimelineFooterCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMTimelineFooterCollectionReusableView.h"

@implementation HEMTimelineFooterCollectionReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [SenseStyle colorWithAClass:[self class]
                                              property:ThemePropertyBackgroundColor];
}

@end
