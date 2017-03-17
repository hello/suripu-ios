//
//  HEMTextCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import "UICollectionViewCell+HEMCard.h"

#import "Sense-Swift.h"

#import "HEMTextCollectionViewCell.h"
#import "HEMStyle.h"
#import "NSString+HEMUtils.h"
#import "NSAttributedString+HEMUtils.h"

static CGFloat const HEMTextCollectionHorzPadding = 24.0f;

@interface HEMTextCollectionViewCell()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* separatorHeightConstraint;

@end

@implementation HEMTextCollectionViewCell

+ (UIFont*)defaultTextFont {
    Class aClass = [HEMCardCollectionViewCell class];
    return [SenseStyle fontWithAClass:aClass property:ThemePropertyTextFont];
}

+ (CGFloat)heightWithText:(NSString*)text font:(UIFont*)font cellWidth:(CGFloat)width {
    CGFloat textWidth = width - (2 * HEMTextCollectionHorzPadding);
    return [text heightBoundedByWidth:textWidth usingFont:font];
}

+ (CGFloat)heightWithAttributedText:(NSAttributedString*)text cellWidth:(CGFloat)width {
    CGFloat textWidth = width - (2 * HEMTextCollectionHorzPadding);
    return [text sizeWithWidth:textWidth].height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureContentView];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureContentView];
    }
    return self;
}

- (void)configureContentView {
    if (![self textLabel]) {
        CGRect frame = CGRectZero;
        frame.origin.x = HEMTextCollectionHorzPadding;
        frame.size.width = CGRectGetWidth([[self contentView] bounds])-(2*HEMTextCollectionHorzPadding);
        frame.size.height = CGRectGetHeight([[self contentView] bounds]);
        
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self contentView] addSubview:label];
        
        [self setTextLabel:label];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [[self contentView] setBackgroundColor:[UIColor clearColor]];
    
    [[self textLabel] setNumberOfLines:0];
    [self applyStyle];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[self textLabel] setText:nil];
    [[self separator] setHidden:YES];
}

- (void)displayAsACard:(BOOL)card {
    [super displayAsACard:YES];
}

- (void)applyStyle {
    [super applyStyle];
    
    Class superClass = [HEMCardCollectionViewCell class];
    UIColor* textColor = [SenseStyle colorWithAClass:superClass property:ThemePropertyTextColor];
    UIFont* font = [[self class] defaultTextFont];
    [[self textLabel] setTextColor:textColor];
    [[self textLabel] setFont:font];
    [[self separator] applySeparatorStyle];
}

@end
