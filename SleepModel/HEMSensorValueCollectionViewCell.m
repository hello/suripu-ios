//
//  HEMSensorValueCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "Sense-Swift.h"

#import "HEMSensorValueCollectionViewCell.h"

@implementation HEMSensorValueCollectionViewCell

+ (UIFont*)valueFont {
    static NSString* valueFontKey = @"sense.value.font";
    return [SenseStyle fontWithAClass:self propertyName:valueFontKey];
}

+ (UIFont*)smallValueUnitFont {
    static NSString* valueFontKey = @"sense.value.unit.font";
    return [SenseStyle fontWithAClass:self propertyName:valueFontKey];
}

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

- (void)applyStyle {
    UIColor* textColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIFont* textFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    [[self messageLabel] setFont:textFont];
    [[self messageLabel] setTextColor:textColor];
}

@end
