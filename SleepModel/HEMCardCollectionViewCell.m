//
//  HEMCardCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"
#import "HelloStyleKit.h"

@implementation HEMCardCollectionViewCell

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)awakeFromNib
{
    NSShadow* shadow = [HelloStyleKit backViewCardShadow];

    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 2.f;
    self.layer.shadowOffset = [shadow shadowOffset];
    self.layer.shadowColor = [[shadow shadowColor] CGColor];
    self.layer.shadowRadius = [shadow shadowBlurRadius];
    self.layer.shadowOpacity = 1.f;
    self.layer.masksToBounds = NO;
}

@end
