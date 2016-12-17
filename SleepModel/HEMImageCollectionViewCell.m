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
    [super awakeFromNib];
    [[self contentView] setBackgroundColor:[UIColor blackColor]];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureImageView];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureImageView];
    }
    return self;
}

- (void)configureImageView {
    if (![self urlImageView]) {
        CGRect imageFrame = [[self contentView] bounds];
        HEMURLImageView* imageView = [[HEMURLImageView alloc] initWithFrame:imageFrame];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [[self contentView] addSubview:imageView];
        [self setUrlImageView:imageView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self urlImageView] cancelImageDownload];
}

@end
