//
//  HEMTimelineHeaderCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 11/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTimelineHeaderCollectionReusableView.h"
#import "HelloStyleKit.h"

@interface HEMTimelineHeaderCollectionReusableView ()
@end

@implementation HEMTimelineHeaderCollectionReusableView

- (void)awakeFromNib {
    self.backgroundColor = [HelloStyleKit timelineGradientColor];
}

@end
