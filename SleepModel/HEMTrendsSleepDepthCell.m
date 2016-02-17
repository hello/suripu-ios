//
//  HEMTrendsSleepDepthCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsSleepDepthCell.h"
#import "HEMScreenUtils.h"
#import "HEMTrendsBubbleView.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsSleepDepthHeight = 240.0f;
static CGFloat const HEMTrendsSleepDepthMinWidthCoef = 0.3f;

@interface HEMTrendsSleepDepthCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lightWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deepWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediumTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediumLeadingConstraint;

@end

@implementation HEMTrendsSleepDepthCell

+ (CGFloat)height {
    return HEMTrendsSleepDepthHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[[self lightBubbleView] nameLabel] setText:[NSLocalizedString(@"trends.sleep-depth.light", nil) uppercaseString]];
    [[self lightBubbleView] setBubbleColor:[UIColor trendsSleepDepthLightColor]];
    
    [[[self mediumBubbleView] nameLabel] setText:[NSLocalizedString(@"trends.sleep-depth.medium", nil) uppercaseString]];
    [[self mediumBubbleView] setBubbleColor:[UIColor trendsSleepDepthMediumColor]];
    
    [[[self deepBubbleView] nameLabel] setText:[NSLocalizedString(@"trends.sleep-depth.deep", nil) uppercaseString]];
    [[self deepBubbleView] setBubbleColor:[UIColor trendsSleepDepthDeepColor]];
}

- (BOOL)layoutSubviewsIfNeeded {
    if (CGRectGetWidth([self bounds]) < CGRectGetWidth([[self mainContentView] bounds])) {
        [self layoutIfNeeded];
        return YES;
    }
    return NO;
}

- (CGFloat)minWidth {
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    return screenWidth * HEMTrendsSleepDepthMinWidthCoef;
}

- (NSString*)valueForPercentage:(CGFloat)percentage {
    CGFloat value = percentage * 100.0f;
    long displayValue = roundCGFloat(value);
    return [NSString stringWithFormat:@"%ld", displayValue];
}

- (void)updateLightPercentage:(CGFloat)lightPercentage
             mediumPercentage:(CGFloat)mediumPercentage
               deepPercentage:(CGFloat)deepPercentage {
    
    BOOL laidOutSubviews = [self layoutSubviewsIfNeeded];

    [[[self lightBubbleView] valueLabel] setText:[self valueForPercentage:lightPercentage]];
    [[[self mediumBubbleView] valueLabel] setText:[self valueForPercentage:mediumPercentage]];
    [[[self deepBubbleView] valueLabel] setText:[self valueForPercentage:deepPercentage]];
    
    CGFloat height = CGRectGetHeight([[self mainContentView] bounds]);
    CGFloat width = CGRectGetWidth([[self mainContentView] bounds]);
    CGFloat minWidth = [self minWidth];
    CGFloat lightWidth = MAX(minWidth, MIN(height, lightPercentage * width));
    CGFloat deepWidth = MAX(minWidth, MIN(height, deepPercentage* width));
    CGFloat spaceForMedium = width - lightWidth - deepWidth;
    CGFloat mediumWidth = MAX(minWidth, MIN(height, mediumPercentage * width));
    CGFloat overlap = absCGFloat((mediumWidth - spaceForMedium) / 2.0f);
    
    [[self lightWidthConstraint] setConstant:lightWidth];
    [[self deepWidthConstraint] setConstant:deepWidth];
    [[self mediumLeadingConstraint] setConstant:-overlap];
    [[self mediumTrailingConstraint] setConstant:overlap];
    
    void(^update)(void) = ^{
        [self layoutIfNeeded];
        [[self lightBubbleView] setNeedsDisplay];
        [[self mediumBubbleView] setNeedsDisplay];
        [[self deepBubbleView] setNeedsDisplay];
    };
    
    if (laidOutSubviews) {
        update();
    } else {
        [UIView animateWithDuration:0.33f animations:update];
    }
    

}

@end
