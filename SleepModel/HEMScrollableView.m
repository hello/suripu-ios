//
//  HEMScrollableView.m
//  Sense
//
//  Created by Jimmy Lu on 11/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIFont+HEMStyle.h"

#import "HEMScrollableView.h"
#import "HEMOnboardingUtils.h"
#import "HelloStyleKit.h"

static CGFloat const HEMScrollabelLabelHorzMargin = 20.0f;
static CGFloat const HEMScrollabelDefaultContentPadding = 10.0f;
static CGFloat const HEMScrollableTitleHeight = 34.0f;
static CGFloat const HEMScrollableBotPadding = 28.0f;

@interface HEMScrollableView()

@property (nonatomic, weak) UIScrollView* scrollView;
@property (nonatomic, weak) UIView* lastContentView; // not the same as lastObject of scrollView subviews
@property (nonatomic, strong) NSMutableArray* yOffsets;

@end

@implementation HEMScrollableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setClipsToBounds:YES];
    [self setYOffsets:[NSMutableArray array]];
    [self addScrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSInteger index = 0;
    UIView* prevView = nil;
    CGFloat margins = (HEMScrollabelLabelHorzMargin*2);
    CGFloat labelMaxWidth = CGRectGetWidth([[self scrollView] bounds])-margins;
    CGSize labelConstraint = CGSizeMake(labelMaxWidth, MAXFLOAT);
    
    for (UIView* subview in [[self scrollView] subviews]) {
        CGFloat yOffset = [[self yOffsets][index++] floatValue];
        CGRect frame = [subview frame];

        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*)subview;
            frame.size.height = [label sizeThatFits:labelConstraint].height;
            frame.origin.y = CGRectGetMaxY([prevView frame]) + yOffset;
        } else if ([subview isKindOfClass:[UIImageView class]]){
            frame.origin.y = CGRectGetMaxY([prevView frame]) + yOffset;
        }
        
        [subview setFrame:frame];
        prevView = subview;
    }

    [self updateContentSize];
    [self addShadowIfScrollRequired];
}

- (void)addScrollView {
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    [scrollView setBackgroundColor:[self backgroundColor]];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:scrollView];
    [self setScrollView:scrollView];
}

- (void)updateContentSize {
    CGSize contentSize = [[self scrollView] contentSize];
    contentSize.width = CGRectGetWidth([[self scrollView] bounds]);
    contentSize.height = CGRectGetMaxY([[self lastContentView] frame])+HEMScrollableBotPadding;
    [[self scrollView] setContentSize:contentSize];
}

- (void)addTitle:(NSString*)title {
    NSDictionary* attributes = @{NSFontAttributeName : [UIFont onboardingTitleFont],
                                 NSForegroundColorAttributeName : [UIColor blackColor]};
    NSAttributedString* attributedTitle
        = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    
    [self addAttributedTitle:attributedTitle withYOffset:0.0f];
}

- (void)addAttributedTitle:(NSAttributedString*)title withYOffset:(CGFloat)y {
    
    CGRect labelFrame = {
        HEMScrollabelLabelHorzMargin,
        CGRectGetMaxY([[self lastContentView] frame])+ y,
        CGRectGetWidth([[self scrollView] bounds])-(HEMScrollabelLabelHorzMargin*2),
        HEMScrollableTitleHeight
    };
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setBackgroundColor:[[self scrollView] backgroundColor]];
    [label setAttributedText:title];
    [label setNumberOfLines:2]; // max two lines
    [[self scrollView] addSubview:label];
    [[self yOffsets] addObject:@(y)];
    [self setLastContentView:label];
    
}

- (void)addImage:(UIImage *)image
     contentMode:(UIViewContentMode)mode
     withYOffset:(CGFloat)yOffset {
    CGRect imageFrame = {
        0.0f,
        CGRectGetMaxY([[self lastContentView] frame]) + yOffset,
        CGRectGetWidth([[self scrollView] bounds]),
        image.size.height
    };
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    [imageView setContentMode:mode];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [imageView setImage:image];
    [imageView setBackgroundColor:[[self scrollView] backgroundColor]];
    
    [[self scrollView] addSubview:imageView];
    [[self yOffsets] addObject:@(yOffset)];
    [self setLastContentView:imageView];
}

- (void)addImage:(UIImage *)image withYOffset:(CGFloat)yOffset {
    [self addImage:image
       contentMode:UIViewContentModeScaleAspectFill
       withYOffset:yOffset];
}

- (void)addImage:(UIImage*)image {
    [self addImage:image withYOffset:0.0f];
}

- (void)addDescription:(NSAttributedString*)attributedDes {
    CGRect labelFrame = {
        HEMScrollabelLabelHorzMargin,
        CGRectGetMaxY([[self lastContentView] frame])+ HEMScrollabelDefaultContentPadding,
        CGRectGetWidth([[self scrollView] bounds])-(HEMScrollabelLabelHorzMargin*2),
        0.0f // will be updated on relayout
    };
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setAttributedText:attributedDes];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [label setBackgroundColor:[[self scrollView] backgroundColor]];
    [label setNumberOfLines:0];
    
    [[self scrollView] addSubview:label];
    [[self yOffsets] addObject:@(HEMScrollabelDefaultContentPadding)];
    [self setLastContentView:label];
}

- (void)addShadowIfScrollRequired {
    CALayer* layer = [self layer];
    if ([[self scrollView] contentSize].height > CGRectGetHeight([[self scrollView] bounds])) {
        NSShadow* shadow = [HelloStyleKit onboardingButtonContainerShadow];
        [layer setShadowRadius:[shadow shadowBlurRadius]];
        [layer setShadowOffset:[shadow shadowOffset]];
        [layer setShadowColor:[[shadow shadowColor] CGColor]];
        [layer setShadowOpacity:1.0f];
    } else {
        [layer setShadowOpacity:0.0f];
    }
}

- (BOOL)scrollRequired {
    return [[self scrollView] contentSize].height > CGRectGetHeight([[self scrollView] bounds]);
}

@end
