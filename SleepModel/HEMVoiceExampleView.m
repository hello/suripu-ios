//
//  HEMVoiceExampleView.m
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"

#import "HEMVoiceExampleView.h"
#import "HEMURLImageView.h"
#import "NSBundle+HEMUtils.h"
#import "NSString+HEMUtils.h"

static CGFloat const kHEMVoiceExampleBaseHeight = 60.0f;
static CGFloat const kHEMVoiceExampleLeftMargin = 74.0f;
static CGFloat const kHEMVoiceExampleRightMargin = 48.0f;

@implementation HEMVoiceExampleView

+ (CGFloat)heightWithExampleText:(NSString*)example withMaxWidth:(CGFloat)maxWidth {
    CGFloat textWidth = maxWidth - kHEMVoiceExampleLeftMargin - kHEMVoiceExampleRightMargin;
    UIFont* exampleFont = [SenseStyle fontWithAClass:self property:ThemePropertyDetailFont];
    CGFloat textHeight = [example heightBoundedByWidth:textWidth usingFont:exampleFont];
    return kHEMVoiceExampleBaseHeight + textHeight;
}

+ (instancetype)exampleViewWithCategoryName:(NSString*)name
                                    example:(NSString*)example
                                    iconURL:(NSString*)iconURL {
    HEMVoiceExampleView* view = [NSBundle loadNibWithOwner:self];
    [[view categoryLabel] setText:name];
    [[view exampleLabel] setText:example];
    [[view iconView] setImageWithURL:iconURL];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self exampleLabel] setNumberOfLines:0];
    [[self iconView] setContentMode:UIViewContentModeScaleAspectFit];
    [[self iconView] setErrorImage:[UIImage imageNamed:@"iconVoiceError"]];
    
    UITapGestureRecognizer* tap = [UITapGestureRecognizer new];
    [self addGestureRecognizer:tap];
    [self setTapGesture:tap];
    
    [self applyStyle];
}

- (void)applyStyle {
    [super applyFillStyle];
    
    UIFont* categoryFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIFont* exampleFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyDetailFont];
    UIColor* categoryColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    UIColor* exampleColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyDetailColor];
    [[self categoryLabel] setFont:categoryFont];
    [[self categoryLabel] setTextColor:categoryColor];
    [[self exampleLabel] setFont:exampleFont];
    [[self exampleLabel] setTextColor:exampleColor];
    [[self separatorView] applySeparatorStyle];
    [[self iconView] setBackgroundColor:[self backgroundColor]];
}

@end
