//
//  HEMImageCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMImageCollectionViewCell.h"
#import "HEMURLImageView.h"

@interface HEMImageCollectionViewCell()

@end

@implementation HEMImageCollectionViewCell

- (void)awakeFromNib {
    [[self contentView] setBackgroundColor:[UIColor blackColor]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self urlImageView] cancelImageDownload];
    [[self urlImageView] setImage:nil];
}

@end
