//
//  HEMBarChartView.m
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMBarChartView.h"
#import "HEMTrendsDisplayPoint.h"
#import "HEMStyle.h"

static CGFloat const HEMBarChartAnimeDuration = 0.2f;
static CGFloat const HEMBarChartBaseLine = 0.0f;
static CGFloat const HEMBarChartBorderWidth = 1.0f;
static CGFloat const HEMBarChartMinimumBarHeight = 40.0f;
static CGFloat const HEMBarChartBarCornerRadiusRatio = 10.0f;

@interface HEMBarChartView()

@property (nonatomic, strong) NSArray<HEMTrendsDisplayPoint*>* values;

@end

@implementation HEMBarChartView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIColor* lineColor = [[UIColor grey6] colorWithAlphaComponent:0.15f];
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMBarChartBorderWidth);
    
    CGFloat y = CGRectGetHeight([self bounds]) - (HEMBarChartBorderWidth / 2.0f);
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth([self bounds]), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

- (void)setDefaults {
    [self setClipsToBounds:YES];
}

- (void)updateBarChartWith:(NSArray<HEMTrendsDisplayPoint*>*)values
                completion:(HEMBarChartAnimCompletion)completion {
    [self setValues:values];
    [self removeCurrentBarsIfNeeded:^{
        NSInteger minIndex = -1;
        NSInteger maxIndex = -1;
        [self renderUpdatedValues:&minIndex maxBarOrigin:&maxIndex];
        [self animateBarsIn:^(BOOL finished) {
            if (completion) {
                completion (minIndex, maxIndex);
            }
        }];
    }];
}

- (void)renderUpdatedValues:(NSInteger*)minIndex maxBarOrigin:(NSInteger*)maxIndex {
    CGFloat fullHeight = CGRectGetHeight([self bounds]);
    CGRect barFrame = CGRectZero;
    barFrame.size.width = [self barWidth];
    barFrame.origin.y = fullHeight; // hide it when added
    
    UIColor* barColor = nil;
    NSInteger index = 0;
    CGFloat minYOrigin = fullHeight;
    CGFloat maxYOrigin = 0.0f;
    
    for (HEMTrendsDisplayPoint* point in [self values]) {
        CGFloat value = [[point value] CGFloatValue];
        
        barColor = [point highlighted] ? [self highlightedBarColor] : [self normalBarColor];
        
        barFrame.origin.x = (index * ([self barWidth] + [self barSpacing]));
        
        if (value == [self maxValue]) {
            barFrame.size.height = fullHeight;
        } else if (value == [self minValue]) {
            barFrame.size.height = HEMBarChartMinimumBarHeight;
        } else if (value == -1) {
            barFrame.size.height = HEMBarChartBaseLine;
        } else {
            CGFloat availableHeight = fullHeight - HEMBarChartMinimumBarHeight;
            CGFloat ratio = value / [self maxValue];
            CGFloat height = HEMBarChartMinimumBarHeight + (ratio * availableHeight);
            barFrame.size.height = height;
        }
        
        if ([point highlighted]) {
            CGFloat expectedY = fullHeight - CGRectGetHeight(barFrame);
            if (expectedY <= minYOrigin) {
                minYOrigin = expectedY;
                *minIndex = index;
            }
            if (expectedY >= maxYOrigin) {
                maxYOrigin = expectedY;
                *maxIndex = index;
            }
        }
        
        HEMBar* bar = [[HEMBar alloc] initWithFrame:barFrame];
        [bar setBarColor:barColor];
        [self addSubview:bar];
        
        index++;
    }
}

- (void)animateBarsIn:(void(^)(BOOL finished))completion {
    CGFloat fullHeight = CGRectGetHeight([self bounds]);
    [UIView animateWithDuration:HEMBarChartAnimeDuration animations:^{
        for (UIView* subview in [self subviews]) {
            CGRect barFrame = [subview frame];
            barFrame.origin.y = fullHeight - CGRectGetHeight(barFrame);
            [subview setFrame:barFrame];
        }
    } completion:completion];
}

- (void)removeCurrentBarsIfNeeded:(void(^)(void))completion {
    if ([[self subviews] count] == 0) {
        completion ();
    } else {
        CGFloat height = CGRectGetHeight([self bounds]);
        [UIView animateWithDuration:HEMBarChartAnimeDuration animations:^{
            for (UIView* subview in [self subviews]) {
                CGRect frame = [subview frame];
                frame.origin.y = height;
                frame.size.height = 0.0f;
                [subview setFrame:frame];
            }
        } completion:^(BOOL finished) {
            [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            completion ();
        }];
    }
}

- (CGRect)frameOfBarAtIndex:(NSInteger)index relativeTo:(UIView*)view {
    CGRect frame = CGRectZero;
    if (index >= 0 && index < [[self subviews] count]) {
        UIView* subview = [self subviews][index];
        frame = [subview convertRect:[subview bounds] toView:view];
    }
    return frame;
}

@end

@implementation HEMBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIRectCorner corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    CGFloat barWidth = CGRectGetWidth(rect);
    CGFloat radius = barWidth / HEMBarChartBarCornerRadiusRatio;
    CGSize radii = CGSizeMake(radius, radius);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect
                                               byRoundingCorners:corners
                                                     cornerRadii:radii];
    [[self barColor] setFill];
    [path fill];
}

@end
