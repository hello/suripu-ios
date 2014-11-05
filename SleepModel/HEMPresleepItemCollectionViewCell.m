//
//  HEMPresleepItemCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 10/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMPresleepItemCollectionViewCell.h"

@implementation HEMPresleepItemCollectionViewCell

- (void)awakeFromNib
{
    self.typeImageView.layer.borderWidth = 1.f;
    self.typeImageView.layer.cornerRadius = CGRectGetWidth(self.typeImageView.bounds) / 2;
}

@end
