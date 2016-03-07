//
//  HEMTrendsCircleView.m
//  Sense
//
//  Created by Jimmy Lu on 2/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsCircleView.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsCircleTitleOffset = -5.0f;

@interface HEMTrendsCircleView()

@property (nonatomic, weak) CAShapeLayer* circleLayer;
@property (nonatomic, weak) UILabel* valueLabel;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, strong) UIColor* circleColor;

@end

@implementation HEMTrendsCircleView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color {
    self = [super initWithFrame:frame];
    if (self) {
        _circleColor = color;
        [self addCircle];
    }
    return self;
}

- (void)addCircle {
    NSShadow* circleShadow = [NSShadow shadowForTrendsSleepDepthCircles];
    
    CAShapeLayer* circle = [CAShapeLayer layer];
    [circle setPath:[[UIBezierPath bezierPathWithOvalInRect:[self bounds]] CGPath]];
    [circle setFrame:[self bounds]];
    [circle setFillColor:[[self circleColor] CGColor]];
    [circle fillColor];
    [circle setShadowColor:[[circleShadow shadowColor] CGColor]];
    [circle setShadowOffset:[circleShadow shadowOffset]];
    [circle setShadowRadius:[circleShadow shadowBlurRadius]];
    [circle setShadowOpacity:1.0f];
    
    [[self layer] addSublayer:circle];
    [self setCircleLayer:circle];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateCirclePath];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateCirclePath];
}

- (void)updateCirclePath {
    UIBezierPath* path = [UIBezierPath bezierPathWithOvalInRect:[self bounds]];
    [[self circleLayer] setPath:[path CGPath]];
}

- (void)setAttributedValue:(NSAttributedString*)attributedValue
                     title:(NSAttributedString*)attributedTitle {
    if (![self valueLabel]) {
        UILabel* valueLabel = [[UILabel alloc] init];
        [self addSubview:valueLabel];
        [self setValueLabel:valueLabel];
    }
    
    if (![self titleLabel]) {
        UILabel* titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        [self setTitleLabel:titleLabel];
    }
    
    [[self valueLabel] setAttributedText:attributedValue];
    [[self titleLabel] setAttributedText:attributedTitle];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[self valueLabel] sizeToFit];
    [[self titleLabel] sizeToFit];

    CGSize valueSize = [[self valueLabel] bounds].size;
    CGSize titleSize = [[self titleLabel] bounds].size;
    CGFloat textHeight = valueSize.height + titleSize.height;
    CGFloat maxHeight = CGRectGetHeight([self bounds]);
    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    
    CGRect valueFrame = [[self valueLabel] frame];
    valueFrame.origin.y = (maxHeight - textHeight) / 2.0f;
    valueFrame.origin.x = (maxWidth - valueSize.width) / 2.0f;
    [[self valueLabel] setFrame:valueFrame];
    
    CGRect titleFrame = [[self titleLabel] frame];
    titleFrame.origin.y = CGRectGetMaxY(valueFrame) + HEMTrendsCircleTitleOffset;
    titleFrame.origin.x = (maxWidth - titleSize.width) / 2.0f;
    [[self titleLabel] setFrame:titleFrame];
}

@end