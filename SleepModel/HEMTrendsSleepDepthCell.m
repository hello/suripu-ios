//
//  HEMTrendsSleepDepthCell.m
//  Sense
//
//  Created by Jimmy Lu on 2/16/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <UICountingLabel/UICountingLabel.h>

#import "HEMTrendsSleepDepthCell.h"
#import "HEMScreenUtils.h"
#import "HEMTrendsBubbleView.h"
#import "HEMScreenUtils.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsSleepDepthHeight = 240.0f;
static CGFloat const HEMTrendsSleepDepthMinWidthCoef = 0.3f;
static CGFloat const HEMTrendsSleepDepthValueFontSizeCoef = 0.33f;
static CGFloat const HEMTrendsSleepDepthUnitFontSizeCoef = 0.167f;

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
    [[self lightBubbleView] setBubbleColor:[UIColor colorForSleepState:SENTimelineSegmentSleepStateLight]];
    
    [[[self mediumBubbleView] nameLabel] setText:[NSLocalizedString(@"trends.sleep-depth.medium", nil) uppercaseString]];
    [[self mediumBubbleView] setBubbleColor:[UIColor colorForSleepState:SENTimelineSegmentSleepStateMedium]];
    
    [[[self deepBubbleView] nameLabel] setText:[NSLocalizedString(@"trends.sleep-depth.deep", nil) uppercaseString]];
    [[self deepBubbleView] setBubbleColor:[UIColor colorForSleepState:SENTimelineSegmentSleepStateSound]];
}

- (CGFloat)minWidth {
    CGFloat screenWidth = CGRectGetWidth(HEMKeyWindowBounds());
    return screenWidth * HEMTrendsSleepDepthMinWidthCoef;
}

- (CGFloat)valueForPercentage:(CGFloat)percentage {
    CGFloat value = percentage * 100.0f;
    return roundCGFloat(value);
}

- (CGFloat)valueFontSizeForBubbleSize:(CGFloat)size {
    return ceilCGFloat(size * HEMTrendsSleepDepthValueFontSizeCoef);
}

- (CGFloat)unitFontSizeForBubbleSize:(CGFloat)size {
    return ceilCGFloat(size * HEMTrendsSleepDepthUnitFontSizeCoef);
}

- (void)updateBubbleFontSizesForBubbleSize:(CGFloat)lightSize
                                mediumSize:(CGFloat)mediumSize
                                  deepSize:(CGFloat)deepSize {
    
    CGFloat lightValueSize = [self valueFontSizeForBubbleSize:lightSize];
    CGFloat mediumValueSize = [self valueFontSizeForBubbleSize:mediumSize];
    CGFloat deepValueSize = [self valueFontSizeForBubbleSize:deepSize];
    
    CGFloat lightUnitSize = [self unitFontSizeForBubbleSize:lightSize];
    CGFloat mediumUnitSize = [self unitFontSizeForBubbleSize:mediumSize];
    CGFloat deepUnitSize = [self unitFontSizeForBubbleSize:deepSize];
    
    [[[self lightBubbleView] valueLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:lightValueSize]];
    [[[self mediumBubbleView] valueLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:mediumValueSize]];
    [[[self deepBubbleView] valueLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:deepValueSize]];
    
    [[[self lightBubbleView] unitLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:lightUnitSize]];
    [[[self mediumBubbleView] unitLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:mediumUnitSize]];
    [[[self deepBubbleView] unitLabel] setFont:[UIFont trendSleepDepthValueFontWithSize:deepUnitSize]];
}

- (void)updateLightPercentage:(CGFloat)lightPercentage
             mediumPercentage:(CGFloat)mediumPercentage
               deepPercentage:(CGFloat)deepPercentage {
    
    [self layoutIfNeeded];
    
    CGFloat height = CGRectGetHeight([[self mainContentView] bounds]);
    CGFloat width = CGRectGetWidth([[self mainContentView] bounds]);
    CGFloat minWidth = [self minWidth];
    CGFloat lightWidth = MAX(minWidth, MIN(height, lightPercentage * width));
    CGFloat deepWidth = MAX(minWidth, MIN(height, deepPercentage* width));
    CGFloat spaceForMedium = width - lightWidth - deepWidth;
    CGFloat mediumWidth = MAX(minWidth, MIN(height, mediumPercentage * width));
    CGFloat overlap = absCGFloat((mediumWidth - spaceForMedium) / 2.0f);
    
    [self updateBubbleFontSizesForBubbleSize:lightWidth
                                  mediumSize:mediumWidth
                                    deepSize:deepWidth];
    
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
    
    CGFloat lightValue = [self valueForPercentage:lightPercentage];
    CGFloat mediumValue = [self valueForPercentage:mediumPercentage];
    CGFloat deepValue = [self valueForPercentage:deepPercentage];
    
    CGFloat const duration = 0.33f;
    [UIView animateWithDuration:duration animations:update];
    [[[self lightBubbleView] valueLabel] countFromCurrentValueTo:lightValue withDuration:duration];
    [[[self mediumBubbleView] valueLabel] countFromCurrentValueTo:mediumValue withDuration:duration];
    [[[self deepBubbleView] valueLabel] countFromCurrentValueTo:deepValue withDuration:duration];
}

@end
