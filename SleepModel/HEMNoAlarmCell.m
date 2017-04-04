//
//  HEMNoAlarmCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/4/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "NSAttributedString+HEMUtils.h"

#import "Sense-Swift.h"

#import "HEMNoAlarmCell.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const kHEMNoAlarmCellBaseHeight = 292.0f;
static CGFloat const kHEMNoAlarmCellHorzMargins = 40.0f;
static CGFloat const kHEMNoAlarmCellHorzMarginsSmall = 20.0f;

@interface HEMNoAlarmCell()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
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

+ (NSDictionary*)textAttributes {
    Class class = [HEMCardCollectionViewCell class];
    UIFont* font = [SenseStyle fontWithAClass:class property:ThemePropertyDetailFont];
    UIColor* color = [SenseStyle colorWithAClass:class property:ThemePropertyDetailColor];
    NSMutableParagraphStyle* para = DefaultBodyParagraphStyle();
    [para setAlignment:NSTextAlignmentCenter];
    return @{NSFontAttributeName : font,
             NSForegroundColorAttributeName : color,
             NSParagraphStyleAttributeName : para};
}

+ (CGFloat)heightWithDetail:(NSString*)detail cellWidth:(CGFloat)width {
    CGFloat horzMargins = [self horizontalMargins];
    CGFloat maxWidth = width - (horzMargins * 2);
    return [detail heightBoundedByWidth:maxWidth attributes:[self textAttributes]]
        + kHEMNoAlarmCellBaseHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGFloat margins = [[self class] horizontalMargins];
    [[self trailingDetailMargin] setConstant:margins];
    [[self leadingDetailMargin] setConstant:margins];
}

- (void)setMessage:(NSString*)text {
    if (!text) {
        return [[self detailLabel] setAttributedText:nil];
    }
    
    NSDictionary* attributes = [[self class] textAttributes];
    NSAttributedString* attributedText =
        [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [[self detailLabel] setAttributedText:attributedText];
}

@end
