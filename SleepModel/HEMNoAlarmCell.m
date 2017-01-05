//
//  HEMNoAlarmCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "NSAttributedString+HEMUtils.h"

#import "HEMNoAlarmCell.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const kHEMNoAlarmCellBaseHeight = 292.0f;
static CGFloat const kHEMNoAlarmCellHorzMargins = 40.0f;
static CGFloat const kHEMNoAlarmCellHorzMarginsSmall = 20.0f;

@interface HEMNoAlarmCell()

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingDetailMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingDetailMargin;

@end

@implementation HEMNoAlarmCell

+ (CGFloat)horizontalMargins {
    return (HEMIsIPhone4Family() || HEMIsIPhone5Family())
        ? kHEMNoAlarmCellHorzMarginsSmall
        : kHEMNoAlarmCellHorzMargins;
}

+ (CGFloat)heightWithDetail:(NSAttributedString*)attributedDetail cellWidth:(CGFloat)width {
    CGFloat horzMargins = [self horizontalMargins];
    CGFloat maxWidth = width - horzMargins;
    return [attributedDetail sizeWithWidth:maxWidth].height + kHEMNoAlarmCellBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[self detailLabel] setFont:[UIFont body]];
    [[self detailLabel] setTextColor:[UIColor detailTextColor]];
    
    CGFloat margins = [[self class] horizontalMargins];
    [[self trailingDetailMargin] setConstant:margins];
    [[self leadingDetailMargin] setConstant:margins];
}

@end
