//
//  HEMVideoCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 8/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMVideoCollectionViewCell.h"
#import "HEMEmbeddedVideoView.h"

@implementation HEMVideoCollectionViewCell

- (void)awakeFromNib {
    [[self contentView] setBackgroundColor:[UIColor blackColor]];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureVideoView];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureVideoView];
    }
    return self;
}

- (void)configureVideoView {
    if (![self videoView]) {
        CGRect imageFrame = [[self contentView] bounds];
        
        HEMEmbeddedVideoView* videoView = [[HEMEmbeddedVideoView alloc] initWithFrame:imageFrame];
        [videoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [videoView setClipsToBounds:YES];
        [[self contentView] addSubview:videoView];
        [self setVideoView:videoView];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self videoView] stop];
}

@end
