//
//  HEMCardCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@implementation HEMCardCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)awakeFromNib
{
    self.layer.cornerRadius = 2.f;
    self.layer.shadowOffset = CGSizeMake(0, -1.f);
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f].CGColor;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.masksToBounds = NO;
}

@end
