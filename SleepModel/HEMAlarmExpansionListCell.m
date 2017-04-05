//
//  HEMAlarmExpansionListCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

CGFloat const kHEMAlarmExpansionViewHeight = 42.0f;

static CGFloat const kHEMAlarmExpansionIconMargin = 18.0f;
static CGFloat const kHEMAlarmExpansionTextPadding = 14.0f;
static CGFloat const kHEMAlarmExpansionSeparatorHeight = 0.5f;

static NSInteger const kHEMAlarmExpansionTagIcon = 10;
static NSInteger const kHEMAlarmExpansionTagLabel = 11;
static NSInteger const kHEMAlarmexpansionTagSepartor = 12;

static NSString* const kHEMAlarmExpansionStyleFontKey = @"sense.expansion.detail.font";
static NSString* const kHEMAlarmExpansionStyleColorKey = @"sense.expansion.detail.color";

#import "Sense-Swift.h"
#import "HEMAlarmExpansionListCell.h"
#import "HEMCardCollectionViewCell.h"

@interface HEMAlarmExpansionListCell()

@property (weak, nonatomic) IBOutlet UIView *expansionsContainer;

@end

@implementation HEMAlarmExpansionListCell

+ (NSDictionary*)attributesForExpansionValueText:(BOOL)enabled {
    NSMutableDictionary* attributes = [[self attributesForExpansionText:enabled] mutableCopy];
    if (enabled) {
        UIColor* color = [SenseStyle colorWithAClass:self property:ThemePropertyTextColor];
        [attributes setValue:color forKey:NSForegroundColorAttributeName];
    }
    return attributes;
}

+ (NSDictionary*)attributesForExpansionText:(BOOL)enabled {
    UIFont* font = [SenseStyle fontWithAClass:self propertyName:kHEMAlarmExpansionStyleFontKey];
    UIColor* color = [SenseStyle colorWithAClass:self propertyName:kHEMAlarmExpansionStyleColorKey];
    UIColor* disabledColor = [SenseStyle colorWithAClass:self property:ThemePropertyTextDisabledColor];
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [attributes setValue:font forKey:NSFontAttributeName];
    [attributes setValue:enabled ? color : disabledColor forKey:NSForegroundColorAttributeName];
    return attributes;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[[self expansionsContainer] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showExpansionWithIcon:(UIImage*)icon
                         text:(NSAttributedString*)attributedText
                         tyep:(NSUInteger)type {
    
    NSInteger numberOfSubviews = [[[self expansionsContainer] subviews] count];
    CGFloat yOrigin = numberOfSubviews * kHEMAlarmExpansionViewHeight;
    UIView* expansionView = [[self expansionsContainer] viewWithTag:type];
    
    if (!expansionView) {
        expansionView = [self expansionViewWithYOrigin:yOrigin
                                                  icon:icon
                                                  text:attributedText
                                                   tag:type];
        [[self expansionsContainer] addSubview:expansionView];
    } else {
        UILabel* label = [expansionView viewWithTag:kHEMAlarmExpansionTagLabel];
        UIImageView* iconView = (id)[expansionView viewWithTag:kHEMAlarmExpansionTagIcon];
        
        [label setAttributedText:attributedText];
        [iconView setImage:icon];
    }
    
}

- (UIView*)expansionViewWithYOrigin:(CGFloat)yOrigin
                               icon:(UIImage*)icon
                               text:(NSAttributedString*)attributedText
                                tag:(NSUInteger)tag {
    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    
    CGRect expansionFrame = CGRectZero;
    expansionFrame.size.width = maxWidth;
    expansionFrame.size.height = kHEMAlarmExpansionViewHeight;
    expansionFrame.origin.y = yOrigin;
    
    UIView* view = [[UIView alloc] initWithFrame:expansionFrame];
    [view setTag:tag];
    
    CGRect separatorFrame = CGRectZero;
    separatorFrame.size.width = maxWidth;
    separatorFrame.size.height = kHEMAlarmExpansionSeparatorHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setTag:kHEMAlarmexpansionTagSepartor];
    
    CGRect iconFrame = CGRectZero;
    iconFrame.size = icon.size;
    iconFrame.origin.x = kHEMAlarmExpansionIconMargin;
    iconFrame.origin.y = (kHEMAlarmExpansionViewHeight - icon.size.height) / 2.0f;
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    [iconView setImage:icon];
    [iconView setTag:kHEMAlarmExpansionTagIcon];
    
    CGFloat labelXOrigin = CGRectGetMaxX(iconFrame) + kHEMAlarmExpansionTextPadding;
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = labelXOrigin;
    labelFrame.size.height = kHEMAlarmExpansionViewHeight;
    labelFrame.size.width = maxWidth - labelXOrigin - kHEMAlarmExpansionIconMargin;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setNumberOfLines:1];
    [label setAttributedText:attributedText];
    [label setTag:kHEMAlarmExpansionTagLabel];
    
    [view addSubview:separator];
    [view addSubview:iconView];
    [view addSubview:label];
    
    return view;
}

- (void)applyStyle {
    [super applyStyle];
    
    static NSString* fontKey = @"sense.expansion.detail.font";
    static NSString* colorKey = @"sense.expansion.detail.color";
    
    BOOL enabled = [[self enabledSwitch] isOn];
    UIColor* separatorColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertySeparatorColor];
    UIColor* normalColor = [SenseStyle colorWithAClass:[self class] propertyName:colorKey];
    UIColor* disabledColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextDisabledColor];
    UIColor* bgColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyBackgroundColor];
    UIColor* textColor = enabled ? normalColor : disabledColor;
    UIFont* textFont = [SenseStyle fontWithAClass:[self class] propertyName:fontKey];
    UIColor* tintColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTintColor];
    
    [[self expansionIconView] setTintColor:enabled ? tintColor : disabledColor];
    
    for (UIView* expansionView in [[self expansionsContainer] subviews]) {
        UIView* separator = [expansionView viewWithTag:kHEMAlarmexpansionTagSepartor];
        UILabel* label = (UILabel*) [expansionView viewWithTag:kHEMAlarmExpansionTagLabel];
        
        if (separator) {
            separator.backgroundColor = separatorColor;
        }
        
        if (label) {
            label.textColor = textColor;
            label.font = textFont;
        }
        
        expansionView.backgroundColor = bgColor;
    }
}

@end
