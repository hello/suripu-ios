//
//  HEMTimelineFooterCollectionReusableView.m
//  Sense
//
//  Created by Delisa Mason on 1/8/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMTimelineFooterCollectionReusableView.h"
#import "HelloStyleKit.h"

@implementation HEMTimelineFooterCollectionReusableView

- (void)awakeFromNib {
    self.backgroundColor = [HelloStyleKit timelineGradientColor];
}

@end
