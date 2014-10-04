//
//  HEMPaddedRoundedLabel.m
//  Sense
//
//  Created by Delisa Mason on 10/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPaddedRoundedLabel.h"

@implementation HEMPaddedRoundedLabel

- (CGSize)intrinsicContentSize
{
    CGSize textSize = [self.text sizeWithAttributes:@{ NSFontAttributeName : self.font }];
    CGSize size = CGSizeMake(textSize.width * 1.3, textSize.height * 1.8f);
    self.layer.cornerRadius = floorf(size.height / 2);
    return size;
}

@end
