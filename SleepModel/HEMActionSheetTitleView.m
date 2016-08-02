//
//  HEMSenseLearnsView.m
//  Sense
//
//  Created by Jimmy Lu on 7/1/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//
#import "HEMActionSheetTitleView.h"
#import "UIFont+HEMStyle.h"
#import "UIColor+HEMStyle.h"
#import "NSString+HEMUtils.h"
#import "HEMScreenUtils.h"

static CGFloat HEMActionSheetTitleHorzPadding = 24.0f;
static CGFloat HEMActionSheetTitleVertPadding = 22.0f;
static CGFloat HEMActionSheetTextSpacing = 12.0f;
static CGFloat HEMActionSheetTitleSeparatorHeight = 0.5f;

@interface HEMActionSheetTitleView() <UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray* linkHandlers;
@property (nonatomic, weak) UITextView* descriptionView;

@end

@implementation HEMActionSheetTitleView

+ (NSAttributedString*)attributedDescriptionFromText:(NSString *)text {
    if (!text) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:[self defaultDescriptionProperties]];
}

+ (NSDictionary*)defaultDescriptionProperties {
    return @{NSFontAttributeName : [UIFont body],
             NSForegroundColorAttributeName : [UIColor detailTextColor]};
}

- (instancetype)initWithTitle:(NSString*)title andDescription:(NSAttributedString*)description {
    self = [super init];
    if (self) {
        [self configureContentWithTitle:title andDescription:description];
    }
    return self;
}

- (UITextView*)textViewWithText:(NSAttributedString*)text origin:(CGFloat)y {
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    CGFloat frameWidth = screenWidth - (2 * HEMActionSheetTitleHorzPadding);
    CGSize constraint = CGSizeMake(frameWidth, MAXFLOAT);
    
    UITextView* view = [UITextView new];
    [view setAttributedText:text];
    [view setScrollEnabled:NO];
    [view setEditable:NO];
    [view setTextContainerInset:UIEdgeInsetsZero];
    [[view textContainer] setLineFragmentPadding:0.0f];
    [view setDelegate:self];
    [view setSelectable:NO];

    CGRect textFrame = CGRectZero;
    textFrame.size.width = frameWidth;
    textFrame.size.height = [view sizeThatFits:constraint].height;
    textFrame.origin.y = y;
    textFrame.origin.x = HEMActionSheetTitleHorzPadding;
    [view setFrame:textFrame];
    
    return view;
}

- (UILabel*)labelWithText:(NSString*)text
                  andFont:(UIFont*)font
                 andColor:(UIColor*)color
                atYOrigin:(CGFloat)y {
    
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
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

- (void)configureContentWithTitle:(NSString*)title andDescription:(NSAttributedString*)description {
    CGFloat maxY = HEMActionSheetTitleVertPadding;
    CGFloat spacing = 0.0f;
    
    if (title) {
        UIColor* titleColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        UILabel* titleLabel = [self labelWithText:title
                                          andFont:[UIFont h5]
                                         andColor:titleColor
                                        atYOrigin:maxY];
        [self addSubview:titleLabel];
        
        maxY = CGRectGetMaxY([titleLabel frame]);
        spacing = HEMActionSheetTextSpacing;
    }
    
    if (description) {
        UITextView* textView = [self textViewWithText:description
                                               origin:maxY + spacing];
        [self addSubview:textView];
        [self setDescriptionView:textView];
        
        maxY = CGRectGetMaxY([textView frame]);
    }
    
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    CGRect frame = [self frame];
    frame.size.width = screenWidth;
    frame.size.height = maxY + HEMActionSheetTitleVertPadding;
    
    [self setFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
}

- (void)drawRect:(CGRect)rect {
    UIColor* lineColor = [UIColor separatorColor];
    
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

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    for (HEMActionSheetTitleLinkHandler handler in [self linkHandlers]) {
        handler (URL);
    }
    return NO;
}

- (void)addLinkHandler:(HEMActionSheetTitleLinkHandler)handler {
    if (![self linkHandlers]) {
        [self setLinkHandlers:[NSMutableArray array]];
    }
    [[self linkHandlers] addObject:[handler copy]];
    [[self descriptionView] setSelectable:YES];
}

@end
