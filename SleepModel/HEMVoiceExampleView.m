//
//  HEMVoiceExampleView.m
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMVoiceExampleView.h"
#import "NSBundle+HEMUtils.h"

@implementation HEMVoiceExampleView

+ (instancetype)exampleViewWithCategoryName:(NSString*)name
                                    example:(NSString*)example
                                  iconImage:(UIImage*)iconImage {
    HEMVoiceExampleView* view = [NSBundle loadNibWithOwner:self];
    [[view categoryLabel] setText:name];
    [[view exampleLabel] setText:example];
    [[view iconView] setImage:iconImage];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self exampleLabel] setNumberOfLines:0];
    [[self iconView] setContentMode:UIViewContentModeCenter];
    
    UITapGestureRecognizer* tap = [UITapGestureRecognizer new];
    [self addGestureRecognizer:tap];
    [self setTapGesture:tap];
    
    [self applyStyle];
}

- (void)applyStyle {
    UIFont* categoryFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIFont* exampleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    UIColor* categoryColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* exampleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    [[self categoryLabel] setFont:categoryFont];
    [[self categoryLabel] setTextColor:categoryColor];
    [[self exampleLabel] setFont:exampleFont];
    [[self exampleLabel] setTextColor:exampleColor];
    [[self separatorView] applySeparatorStyle];
}

@end
