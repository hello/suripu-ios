//
//  HEMSensorValueCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorValueCollectionViewCell.h"

@implementation HEMSensorValueCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self valueReplacementImageView] setHidden:YES];
    [[self valueReplacementImageView] setContentMode:UIViewContentModeCenter];
}

- (void)replaceValueWithImage:(UIImage*)image {
    BOOL hideLabel = image != nil;
    [[self valueLabel] setHidden:hideLabel];
    [[self valueReplacementImageView] setHidden:!hideLabel];
    [[self valueReplacementImageView] setImage:image];
}

@end
