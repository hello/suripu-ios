//
//  HEMDeviceActionCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIColor+HEMStyle.h"

#import "HEMDeviceActionCell.h"

@interface HEMDeviceActionCell()

@end

@implementation HEMDeviceActionCell

- (void)awakeFromNib {
    [self setBackgroundColor:[UIColor whiteColor]];
    [[self topSeparatorView] setBackgroundColor:[UIColor separatorColor]];
    [[self separatorView] setBackgroundColor:[UIColor separatorColor]];
}

- (void)prepareForReuse {
    [[self topSeparatorView] setHidden:YES];
}

@end
