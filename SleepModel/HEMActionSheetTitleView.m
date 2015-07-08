//
//  HEMSenseLearnsView.m
//  Sense
//
//  Created by Jimmy Lu on 7/1/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import "UIFont+HEMStyle.h"
#import "NSString+HEMUtils.h"

#import "HEMActionSheetTitleView.h"
#import "HelloStyleKit.h"

static CGFloat HEMActionSheetTitleHorzPadding = 24.0f;
static CGFloat HEMActionSheetTitleVertPadding = 22.0f;
static CGFloat HEMActionSheetTextSpacing = 12.0f;
static CGFloat HEMActionSheetTitleSeparatorHeight = 0.5f;

@implementation HEMActionSheetTitleView

- (instancetype)initWithTitle:(NSString*)title andDescription:(NSString*)description {
    self = [super init];
    if (self) {
        [self configureContentWithTitle:title andDescription:description];
    }
    return self;
}

- (UILabel*)labelWithText:(NSString*)text
                  andFont:(UIFont*)font
                 andColor:(UIColor*)color
                atYOrigin:(CGFloat)y {
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGFloat frameWidth = screenWidth - (2 * HEMActionSheetTitleHorzPadding);
    CGFloat textHeight = [text heightBoundedByWidth:frameWidth usingFont:font];
    
    CGRect frame = CGRectZero;
    frame.size.width = frameWidth;
    frame.size.height = ceilf(textHeight);
    frame.origin.x = HEMActionSheetTitleHorzPadding;
    frame.origin.y = y;
    
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    [label setFont:font];
    [label setTextColor:color];
    [label setText:text];
    [label setNumberOfLines:0];
    
    return label;
}

- (void)configureContentWithTitle:(NSString*)title andDescription:(NSString*)description {
    CGFloat maxY = HEMActionSheetTitleVertPadding;
    CGFloat spacing = 0.0f;
    
    if (title) {
        UIColor* titleColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        UIFont* titleFont = [UIFont actionSheetTitleViewTitleFont];
        UILabel* titleLabel = [self labelWithText:title
                                          andFont:titleFont
                                         andColor:titleColor
                                        atYOrigin:maxY];
        [self addSubview:titleLabel];
        
        maxY = CGRectGetMaxY([titleLabel frame]);
        spacing = HEMActionSheetTextSpacing;
    }
    
    if (description) {

        UIColor* descColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
        UIFont* descFont = [UIFont actionSheetTitleViewDescriptionFont];
        UILabel* descLabel = [self labelWithText:description
                                         andFont:descFont
                                        andColor:descColor
                                       atYOrigin:maxY + spacing];
        [self addSubview:descLabel];
        
        maxY = CGRectGetMaxY([descLabel frame]);
    }
    
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    CGRect frame = [self frame];
    frame.size.width = screenWidth;
    frame.size.height = maxY + HEMActionSheetTitleVertPadding;
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)drawRect:(CGRect)rect {
    UIColor* lineColor = [HelloStyleKit actionSheetSeparatorColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetStrokeColorWithColor(context, [lineColor CGColor]);
    CGContextSetLineWidth(context, HEMActionSheetTitleSeparatorHeight);
    
    CGFloat y = CGRectGetHeight(rect) - (HEMActionSheetTitleSeparatorHeight / 2);
    CGContextMoveToPoint(context, 0.0f, y);
    CGContextAddLineToPoint(context, CGRectGetWidth(rect), y);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
