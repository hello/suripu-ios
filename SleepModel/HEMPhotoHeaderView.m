//
//  HEMPhotoHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMPhotoHeaderView.h"
#import "HEMProfileImageView.h"

@interface HEMPhotoHeaderView() <HEMProfileImageLoadDelegate>

@end

@implementation HEMPhotoHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self imageView] setLoadDelegate:self];
    [self applyStyle];
}

- (void)willLoadImageIn:(HEMProfileImageView *)imageView {
    [[self addButton] setHidden:YES];
}

- (void)didFinishLoadingIn:(HEMProfileImageView *)imageView {
    [[self addButton] setHidden:NO];
}

- (void)applyStyle {
    [self setBackgroundColor:[SenseStyle colorWithGroup:GroupListItem property:ThemePropertyBackgroundColor]];
    [[self imageView] setBackgroundColor:[self backgroundColor]];

    UIImage* addIcon = [SenseStyle imageWithAClass:[self class] property:ThemePropertyIconImage];
    [[self addButton] setImage:addIcon forState:UIControlStateNormal];
}

@end
