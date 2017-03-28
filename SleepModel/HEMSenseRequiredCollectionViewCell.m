//
//  HEMSenseRequiredCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 11/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

#import "HEMSenseRequiredCollectionViewCell.h"
#import "HEMScreenUtils.h"

static NSString* const kHEMNoSenseImageKey = @"sense.warning.image";
static CGFloat const kHEMSenseRequiredTextVertPadding = 24.0f;
static CGFloat const kHEMSenseRequiredTextHorzPadding = 40.0f;
static CGFloat const kHEMSenseRequiredTextHorzPaddingSmall = 20.0f;
static CGFloat const kHEMSenseRequiredButtonHeight = 56.0f;
static CGFloat const kHEMSenseRequiredButtonBottomPadding = 8.0f;

@interface HEMSenseRequiredCollectionViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingDescriptionConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingDescriptionConstraint;

@end

@implementation HEMSenseRequiredCollectionViewCell

+ (CGFloat)horizontalTextPadding {
    return HEMIsIPhone4Family() || HEMIsIPhone5Family()
        ? kHEMSenseRequiredTextHorzPaddingSmall
        : kHEMSenseRequiredTextHorzPadding;
}

+ (NSDictionary*)descriptionAttributes {
    UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    NSMutableParagraphStyle* style = DefaultBodyParagraphStyle();
    [style setAlignment:NSTextAlignmentCenter];
    return @{NSFontAttributeName : font,
             NSForegroundColorAttributeName : color,
             NSParagraphStyleAttributeName : style};
}

+ (CGFloat)heightWithDescription:(NSString*)description withCellWidth:(CGFloat)width {
    UIImage* noSenseImage = [SenseStyle imageWithAClass:[self class] propertyName:kHEMNoSenseImageKey];
    CGFloat maxTextWidth = width - ([self horizontalTextPadding] * 2);
    CGFloat textHeight = [description heightBoundedByWidth:maxTextWidth
                                                attributes:[self descriptionAttributes]];
    return noSenseImage.size.height
        + kHEMSenseRequiredTextVertPadding
        + textHeight
        + kHEMSenseRequiredTextVertPadding
        + kHEMSenseRequiredButtonHeight
        + kHEMSenseRequiredButtonBottomPadding;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CGFloat margin = [[self class] horizontalTextPadding];
    [[self trailingDescriptionConstraint] setConstant:margin];
    [[self leadingDescriptionConstraint] setConstant:margin];
    
    [self applyStyle];
}

- (void)setDescription:(NSString*)text {
    NSDictionary* attributes = [[self class] descriptionAttributes];
    NSAttributedString* aDescription = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:attributes];
    [[self descriptionLabel] setAttributedText:aDescription];
}
    
- (void)applyStyle {
    [super applyStyle];
    [[self illustrationView] setImage:[SenseStyle imageWithAClass:[self class]
                                                     propertyName:kHEMNoSenseImageKey]];
}

@end
