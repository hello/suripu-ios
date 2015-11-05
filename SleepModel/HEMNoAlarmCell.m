//
//  HEMNoAlarmCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMNoAlarmCell.h"
#import "HEMScreenUtils.h"

@interface HEMNoAlarmCell()

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingDetailMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingDetailMargin;

@end

@implementation HEMNoAlarmCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self detailLabel] setFont:[UIFont emptyStateDescriptionFont]];
    
    if (HEMIsIPhone4Family() || HEMIsIPhone5Family()) {
        CGFloat const MARGIN = 20.0f;
        [[self trailingDetailMargin] setConstant:MARGIN];
        [[self leadingDetailMargin] setConstant:MARGIN];
    }
}

@end
