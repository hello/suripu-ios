//
//  HEMNewProfileCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMNewProfileCollectionViewCell.h"
#import "HEMProfileImageView.h"

@interface HEMNewProfileCollectionViewCell() <HEMProfileImageLoadDelegate>

@end

@implementation HEMNewProfileCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self profileImageView] setLoadDelegate:self];
}

- (void)willLoadImageIn:(HEMProfileImageView *)imageView {
    [[self photoChangeButton] setHidden:YES];
}

- (void)didFinishLoadingIn:(HEMProfileImageView *)imageView {
    [[self photoChangeButton] setHidden:NO];
}

@end
