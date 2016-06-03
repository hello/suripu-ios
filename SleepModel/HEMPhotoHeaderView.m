//
//  HEMPhotoHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPhotoHeaderView.h"
#import "HEMProfileImageView.h"

@interface HEMPhotoHeaderView() <HEMProfileImageLoadDelegate>

@end

@implementation HEMPhotoHeaderView

- (void)awakeFromNib {
    [[self imageView] setLoadDelegate:self];
}

- (void)willLoadImageIn:(HEMProfileImageView *)imageView {
    [[self addButton] setHidden:YES];
}

- (void)didFinishLoadingIn:(HEMProfileImageView *)imageView {
    [[self addButton] setHidden:NO];
}

@end
