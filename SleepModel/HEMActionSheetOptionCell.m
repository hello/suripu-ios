//
//  HEMActionSheetOptionCell.m
//  Sense
//
//  Created by Jimmy Lu on 4/22/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HelloStyleKit.h"
#import "HEMActionSheetOptionCell.h"

@implementation HEMActionSheetOptionCell

- (void)awakeFromNib {
    [[self titleLabel] setFont:[UIFont actionSheetOptionTitleFont]];
    [[self descriptionLabel] setFont:[UIFont actionSheetOptionDescriptionFont]];
}

@end
