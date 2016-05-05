//
//  HEMTrendsBaseCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsBaseCell.h"
#import "HEMTrendsAverageView.h"
#import "HEMStyle.h"

static CGFloat const HEMTrendsAveragesHeight = 52.0f;
static CGFloat const HEMTrendsAveragesBotMargin = 20.0f;
static CGFloat const HEMTrendsCellLoadingAlpha = 0.5f;
static CGFloat const HEMTrendsCellLoadingAnimeDuration = 1.0f;

@interface HEMTrendsBaseCell()

@property (nonatomic, strong) UIView* loadingOverlay;
@property (nonatomic, strong) CAGradientLayer* indicatorLayer;

@end

@implementation HEMTrendsBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [[self titleLabel] setFont:[UIFont cardTitleFont]];
    [[self titleLabel] setTextColor:[UIColor grey6]];
    [[self titleSeparator] setBackgroundColor:[UIColor separatorColor]];
    [[[self titleSeparator] layer] setMasksToBounds:YES];
    [self setUserInteractionEnabled:NO];
}

- (void)setAverageTitles:(NSArray<NSAttributedString*>*)titles
                  values:(NSArray<NSAttributedString*>*)values {
    
    if (!titles || !values || [titles count] != [values count] || [titles count] != 3) {
        [[self averagesHeightConstraint] setConstant:0.0f];
        [[self averagesBottomConstraint] setConstant:0.0f];
    } else {
        [[self averagesHeightConstraint] setConstant:HEMTrendsAveragesHeight];
        [[self averagesBottomConstraint] setConstant:HEMTrendsAveragesBotMargin];
        
        [[[self averagesView] average1TitleLabel] setAttributedText:[titles firstObject]];
        [[[self averagesView] average2TitleLabel] setAttributedText:titles[1]];
        [[[self averagesView] average3TitleLabel] setAttributedText:[titles lastObject]];
        
        [[[self averagesView] average1ValueLabel] setAttributedText:[values firstObject]];
        [[[self averagesView] average2ValueLabel] setAttributedText:values[1]];
        [[[self averagesView] average3ValueLabel] setAttributedText:[values lastObject]];
    }
}

- (CAGradientLayer*)indicatorLayer {
    if (!_indicatorLayer) {
        CGRect layerFrame = CGRectZero;
        layerFrame.size.height = CGRectGetHeight([[self titleSeparator] bounds]);
        layerFrame.size.width = CGRectGetWidth([[self titleSeparator] bounds]) / 3.0f;
        layerFrame.origin.x = -CGRectGetWidth(layerFrame);
        
        CAGradientLayer* layer = [CAGradientLayer layer];
        [layer setFrame:layerFrame];
        [layer setColors:[UIColor loadingIndicatorColorRefs]];
        [layer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [layer setStartPoint:CGPointMake(0, 0.5f)];
        [layer setEndPoint:CGPointMake(1, 0.5f)];
        [layer setCornerRadius:CGRectGetHeight(layerFrame) / 2];
        
        _indicatorLayer = layer;
    }
    return _indicatorLayer;
}

- (UIView*)loadingOverlay {
    if (!_loadingOverlay) {
        UIColor* bgColor = [UIColor colorWithWhite:1.0f alpha:HEMTrendsCellLoadingAlpha];
        UIView* overlay = [UIView new];
        [overlay setBackgroundColor:bgColor];
        _loadingOverlay = overlay;
    }
    return _loadingOverlay;
}

- (void)startLoadingAnimation {
    CGFloat fullWidth = CGRectGetWidth([[self titleSeparator] bounds]);
    CGFloat width = CGRectGetWidth([[self indicatorLayer] bounds]);
    CGPoint startPosition = CGPointMake(-width, 0.0f);
    CGPoint endPosition = CGPointMake(fullWidth, 0.0f);
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setFromValue:[NSValue valueWithCGPoint:startPosition]];
    [animation setToValue:[NSValue valueWithCGPoint:endPosition]];
    [animation setDuration:HEMTrendsCellLoadingAnimeDuration];
    [animation setRepeatCount:MAXFLOAT];
    [[self indicatorLayer] setPosition:endPosition];
    [[self indicatorLayer] addAnimation:animation forKey:@"position"];
}

- (void)setLoading:(BOOL)loading {
    if (loading) {
        [[self loadingOverlay] setFrame:[self bounds]];
        [[self contentView] addSubview:[self loadingOverlay]];
        [[self contentView] bringSubviewToFront:[self titleSeparator]];
        [[[self titleSeparator] layer] addSublayer:[self indicatorLayer]];
        [self startLoadingAnimation];
    } else {
        [[self loadingOverlay] removeFromSuperview];
        [[self indicatorLayer] removeAllAnimations];
        [[self indicatorLayer] removeFromSuperlayer];
    }
}

@end
