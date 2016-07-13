//
//  HEMPillCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 7/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPillCollectionViewCell.h"
#import "HEMStyle.h"

static CGFloat const HEMPillCollectionViewBaseHeight = 224.0f;
static CGFloat const HEMPillCollectionViewWithUpdateHeight = 304.0f;

@implementation HEMPillCollectionViewCell

+ (CGFloat)heightWithFirmwareUpdate:(BOOL)firmwareUpdate {
    return firmwareUpdate
            ? HEMPillCollectionViewWithUpdateHeight
            : HEMPillCollectionViewBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self firmwareLabel] setFont:[UIFont body]];
    [[self firmwareLabel] setTextColor:[UIColor grey5]];
    [[self firmwareValueLabel] setFont:[UIFont body]];
    [[self firmwareValueLabel] setTextColor:[UIColor grey6]];
}

@end
