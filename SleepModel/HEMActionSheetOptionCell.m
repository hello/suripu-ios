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

static CGFloat const HEMActionSheetOptionLabelSpacing = 4.0f;
static CGFloat const HEMActionSheetOptionMargin = 20.0f;

@interface HEMActionSheetOptionCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionBottomConstraint;

@end

@implementation HEMActionSheetOptionCell

+ (CGFloat)heightWithTitle:(NSString*)title
               description:(NSString*)description
                  maxWidth:(CGFloat)width {
    
    CGFloat height = HEMActionSheetOptionMargin;
    
    UIFont* titleFont = [UIFont actionSheetOptionTitleFont];
    height += [self heightForText:title usingFont:titleFont constrainedToWidth:width];
    
    if ([description length] > 0) {
        height += HEMActionSheetOptionLabelSpacing;
        
        UIFont* descFont = [UIFont actionSheetOptionDescriptionFont];
        height += [self heightForText:description usingFont:descFont constrainedToWidth:width];
    }
    
    height += HEMActionSheetOptionMargin;
    
    return ceilf(height);
}

+ (CGFloat)heightForText:(NSString*)text usingFont:(UIFont*)font constrainedToWidth:(CGFloat)width {
    NSDictionary* attributes = @{NSFontAttributeName : font};
    CGSize constraint = CGSizeMake(width-(2*HEMActionSheetOptionMargin), MAXFLOAT);
    return [text boundingRectWithSize:constraint
                                  options:NSStringDrawingUsesFontLeading
                                          |NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size.height;
}

- (void)awakeFromNib {
    [[self titleLabel] setFont:[UIFont actionSheetOptionTitleFont]];
    [[self descriptionLabel] setFont:[UIFont actionSheetOptionDescriptionFont]];
}

- (void)prepareForReuse {
    [[self titleLabel] setText:nil];
    [[self descriptionLabel] setText:nil];
    [[self descriptionLabel] sizeToFit];
}

- (void)setDescription:(NSString*)description {
    [[self descriptionLabel] setText:description];
    [[self descriptionLabel] sizeToFit];
}

@end
