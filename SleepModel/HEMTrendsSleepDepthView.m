//
//  HEMTrendsSleepDepthView.m
//  Sense
//
//  Created by Jimmy Lu on 2/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSMutableAttributedString+HEMFormat.h"

#import "HEMTrendsSleepDepthView.h"
#import "HEMTrendsCircleView.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsBubbleMinOverlap = 14.0f;
static CGFloat const HEMTrendsBubbleMinHeightRatio = 0.32f;
static CGFloat const HEMTrendsBubbleAnimationDuration = 0.3f;
static CGFloat const HEMTrendsBubbleValueFontSizeRatio = 0.33f;
static CGFloat const HEMTrendsBubbleUnitFontSizeRatio = 0.17f;

@interface HEMTrendsSleepDepthView()

@property (strong, nonatomic) HEMTrendsCircleView* lightBubble;
@property (strong, nonatomic) HEMTrendsCircleView* mediumBubble;
@property (strong, nonatomic) HEMTrendsCircleView* deepBubble;

@property (assign, nonatomic) CGFloat lightPercentage;
@property (assign, nonatomic) CGFloat mediumPercentage;
@property (assign, nonatomic) CGFloat deepPercentage;

@property (copy, nonatomic) NSAttributedString* lightTitle;
@property (copy, nonatomic) NSAttributedString* mediumTitle;
@property (copy, nonatomic) NSAttributedString* deepTitle;

@end

@implementation HEMTrendsSleepDepthView

- (void)setLightPercentage:(CGFloat)lightPercentage
            localizedTitle:(NSString*)localizedTitle {
    [self setLightPercentage:lightPercentage];
    [self setLightTitle:[self attributedTitle:localizedTitle]];
}

- (void)setMediumPercentage:(CGFloat)mediumPercentage
             localizedTitle:(NSString*)localizedTitle {
    [self setMediumPercentage:mediumPercentage];
    [self setMediumTitle:[self attributedTitle:localizedTitle]];
}

- (void)setDeepPercentage:(CGFloat)deepPercentage
           localizedTitle:(NSString*)localizedTitle {
    [self setDeepPercentage:deepPercentage];
    [self setDeepTitle:[self attributedTitle:localizedTitle]];
}

- (NSAttributedString*)attributedTitle:(NSString*)title {
    if (!title) {
        return nil;
    }
    
    NSDictionary* attributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                 NSFontAttributeName : [UIFont trendSleepDepthTitleFont]};
    return [[NSAttributedString alloc] initWithString:[title uppercaseString] attributes:attributes];
}

/**
 * @discussion
 *
 * Typically this type of logic would sit in a presenter that calls depends on
 * this class, but we will need to animate the numbers, which may make this
 * difficult to do.  Not sure yet tho. TODO.
 */
- (NSAttributedString*)attributedValue:(CGFloat)value {
    CGFloat percentage = value * 100.0f;
    long displayValue = roundCGFloat(percentage);
    
    CGFloat size = [self sizeForBubbleWithPercentage:value].width;
    
    NSString* percent = NSLocalizedString(@"measurement.percentage.unit", nil);
    CGFloat percentSize = ceilCGFloat(size * HEMTrendsBubbleUnitFontSizeRatio);
    UIFont* percentFont = [UIFont trendSleepDepthValueFontWithSize:percentSize];
    NSNumber* baselineOffset = @(2 * (percentSize / 3.0f));
    NSDictionary* percentAttributes = @{NSFontAttributeName : percentFont,
                                        NSForegroundColorAttributeName : [UIColor whiteColor],
                                        NSBaselineOffsetAttributeName : baselineOffset};
    
    NSAttributedString* attributedPercent
        = [[NSAttributedString alloc] initWithString:percent attributes:percentAttributes];
    
    CGFloat fontSize = ceilCGFloat(size * HEMTrendsBubbleValueFontSizeRatio);
    UIFont* font = [UIFont trendSleepDepthValueFontWithSize:fontSize];
    NSString* valueText = [NSString stringWithFormat:@"%ld", displayValue];
    NSDictionary* valueAttributes = @{NSFontAttributeName : font,
                                      NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString* attributedValue
        = [[NSAttributedString alloc] initWithString:valueText attributes:valueAttributes];
    
    NSArray* args = @[attributedValue, attributedPercent];
    return [[NSMutableAttributedString alloc] initWithFormat:@"%@%@" args:args];
}

- (void)render {
    if ([self lightBubble] && [self mediumBubble] && [self deepBubble]) {
        [UIView animateWithDuration:HEMTrendsBubbleAnimationDuration
                         animations:^{
                             [self updateBubbleLayout];
                             [self updateText];
                         }];
    } else {
        [self setLightBubble:[self bubbleViewWithPercentage:[self lightPercentage]
                                                   andColor:[UIColor sleepStateLightColor]]];
        [self setMediumBubble:[self bubbleViewWithPercentage:[self mediumPercentage]
                                                    andColor:[UIColor sleepStateMediumColor]]];
        [self setDeepBubble:[self bubbleViewWithPercentage:[self deepPercentage]
                                                  andColor:[UIColor sleepStateSoundColor]]];
        
        [self addSubview:[self lightBubble]];
        [self addSubview:[self deepBubble]];
        [self addSubview:[self mediumBubble]]; // let it sit above all
    }
}

- (void)updateText {
    [[self lightBubble] setAttributedValue:[self attributedValue:[self lightPercentage]] title:[self lightTitle]];
    [[self mediumBubble] setAttributedValue:[self attributedValue:[self mediumPercentage]] title:[self mediumTitle]];
    [[self deepBubble] setAttributedValue:[self attributedValue:[self deepPercentage]] title:[self deepTitle]];
}

- (CGSize)sizeForBubbleWithPercentage:(CGFloat)percentage {
    CGFloat maxHeight = CGRectGetWidth([self bounds]) - (2 * HEMTrendsBubbleMinOverlap); // make it hug the sides
    CGFloat minHeight = maxHeight * HEMTrendsBubbleMinHeightRatio;
    CGFloat size = MAX(minHeight, maxHeight * percentage);
    return CGSizeMake(size, size);
}

- (HEMTrendsCircleView*)bubbleViewWithPercentage:(CGFloat)percentage andColor:(UIColor*)color {
    CGRect bubbleFrame = CGRectZero;
    bubbleFrame.size = [self sizeForBubbleWithPercentage:percentage];
    return [[HEMTrendsCircleView alloc] initWithFrame:bubbleFrame color:color];
}

- (void)updateBubbleLayout {
    // remember, width and height is the same (circle) so they are interchangeable
    CGFloat lightWidth = CGRectGetWidth([[self lightBubble] bounds]);
    CGFloat mediumWidth = CGRectGetWidth([[self mediumBubble] bounds]);
    CGFloat deepWidth = CGRectGetWidth([[self deepBubble] bounds]);
    CGFloat containerHeight = CGRectGetHeight([self bounds]);
    CGFloat containerWidth = CGRectGetWidth([self bounds]);
    
    CGRect bubbleBounds = [[self lightBubble] bounds];
    CGFloat radius = CGRectGetWidth(bubbleBounds) / 2.0f;
    bubbleBounds.size = [self sizeForBubbleWithPercentage:[self lightPercentage]];
    [[self lightBubble] setBounds:bubbleBounds];
    [[self lightBubble] setCenter:CGPointMake(radius, ((containerHeight - lightWidth) / 2) + radius)];
    
    bubbleBounds = [[self deepBubble] bounds];
    bubbleBounds.size = [self sizeForBubbleWithPercentage:[self deepPercentage]];
    radius = CGRectGetWidth(bubbleBounds) / 2.0f;
    CGPoint center = CGPointZero;
    center.x = (containerWidth - CGRectGetWidth(bubbleBounds)) + radius;
    center.y = ((containerHeight - deepWidth) / 2) + radius;
    [[self deepBubble] setBounds:bubbleBounds];
    [[self deepBubble] setCenter:center];
    
    CGFloat maxLightX = CGRectGetMaxX([[self lightBubble] frame]);
    CGFloat minDeepX = CGRectGetMinX([[self deepBubble] frame]);
    CGFloat distanceBetweenLightAndDeep = minDeepX - maxLightX;
    CGFloat centerMediumX = maxLightX + (distanceBetweenLightAndDeep / 2);
    
    bubbleBounds = [[self mediumBubble] bounds];
    bubbleBounds.size = [self sizeForBubbleWithPercentage:[self mediumPercentage]];
    radius = CGRectGetWidth(bubbleBounds) / 2.0f;
    center.x = centerMediumX - (CGRectGetWidth(bubbleBounds) / 2) + radius;
    center.y = ((containerHeight - mediumWidth) / 2) + radius;
    [[self mediumBubble] setBounds:bubbleBounds];
    [[self mediumBubble] setCenter:center];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateBubbleLayout];
    [self updateText];
}

@end
