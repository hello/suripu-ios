
#import <UICountingLabel/UICountingLabel.h>
#import "HEMSleepScoreGraphView.h"
#import "SENSensorAccessibility.h"
#import "HEMStyle.h"

@interface HEMSleepScoreGraphView ()

@property (nonatomic) NSInteger sleepScore;
@property (nonatomic) SENCondition condition;
@property (nonatomic, strong) CAShapeLayer *scoreLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@property (nonatomic, strong) CAShapeLayer *loadingLayer;
@property (nonatomic, strong) CAGradientLayer* highlightedLayer;
@property (nonatomic, weak) IBOutlet UICountingLabel *scoreValueLabel;
@end

@implementation HEMSleepScoreGraphView

NSString *const scoreLoadingAnimation = @"scoreLoadingAnimation";
CGFloat const HEMSleepScoreAnimationDuration = 1.2f;
CGFloat const arcAngleStart = M_PI / 2 + M_PI / 4;
CGFloat const maxEndAngle = 3 * M_PI / 2;
CGFloat const maxScoreValue = 100.f;
CGFloat const arcOffsetX = 78.f;
CGFloat const arcOffsetY = 80.f;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureLayers];
    [self configureScoreValueLabel];
    self.accessibilityLabel = NSLocalizedString(@"timeline.accessibility-label.summary-score", nil);
    self.isAccessibilityElement = YES;
}

- (void)configureLayers {
    self.scoreLayer = [CAShapeLayer layer];
    self.backgroundLayer = [CAShapeLayer layer];
    self.loadingLayer = [CAShapeLayer layer];
    self.backgroundLayer.opacity = 0;
    self.loadingLayer.opacity = 0;
    [self.layer addSublayer:self.backgroundLayer];
    [self.layer addSublayer:self.loadingLayer];
    NSInteger radius = floorf(CGRectGetWidth(self.bounds) / 2);
    UIColor *fillColor = [UIColor clearColor];
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcOffsetX, arcOffsetY)
                                                           radius:radius
                                                       startAngle:arcAngleStart
                                                         endAngle:M_PI / 4
                                                        clockwise:YES];
    self.backgroundLayer.path = arcPath.CGPath;
    self.backgroundLayer.fillColor = fillColor.CGColor;
    self.backgroundLayer.strokeColor = [UIColor borderColor].CGColor;
    self.backgroundLayer.lineWidth = 1.f;
    self.backgroundLayer.frame = self.bounds;
    self.loadingLayer.fillColor = fillColor.CGColor;
    self.loadingLayer.path = arcPath.CGPath;
    self.loadingLayer.strokeColor = [UIColor tintColor].CGColor;
    self.loadingLayer.lineWidth = 1.f;
    self.loadingLayer.frame = self.bounds;
    self.backgroundLayer.opacity = 1;
}

- (void)configureScoreValueLabel {
    self.scoreValueLabel.animationDuration = HEMSleepScoreAnimationDuration;
    self.scoreValueLabel.formatBlock = ^NSString *(float value) { return [NSString stringWithFormat:@"%0.f", value]; };
    self.scoreValueLabel.alpha = 0;
    self.scoreValueLabel.method = UILabelCountingMethodEaseInOut;
    self.scoreValueLabel.font = [UIFont h1];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        if (!self.highlightedLayer) {
            CAShapeLayer* mask = [CAShapeLayer layer];
            mask.frame = self.backgroundLayer.bounds;
            mask.path = self.backgroundLayer.path;
            
            CAGradientLayer* gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = self.backgroundLayer.bounds;
            gradientLayer.colors = [UIColor timelineSelectedGradientColorRefs];
            gradientLayer.mask = mask;
            
            self.highlightedLayer = gradientLayer;
        }
        [self.layer insertSublayer:self.highlightedLayer atIndex:0];
    } else {
        [self.highlightedLayer removeFromSuperlayer];
    }
}

#pragma mark - Score Animation

- (void)animateScoreTo:(CGFloat)value {
    NSString *const arcAnimationKey = @"drawCircleAnimation";
    NSString *const colorAnimationKey = @"colorCircleAnimation";
    self.scoreValueLabel.alpha = 0;
    [self.scoreLayer removeFromSuperlayer];
    if (value <= 0)
        return;

    CGFloat scale = (value / maxScoreValue);
    CGFloat endAngle = (maxEndAngle * scale) + arcAngleStart;
    NSInteger radius = floorf(CGRectGetWidth(self.bounds) / 2);
    CAShapeLayer *circle = self.scoreLayer;
    circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcOffsetX, arcOffsetY)
                                                 radius:radius
                                             startAngle:arcAngleStart
                                               endAngle:endAngle
                                              clockwise:YES]
                      .CGPath;
    circle.frame = self.bounds;
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor colorForCondition:self.condition].CGColor;
    circle.lineWidth = 1;
    CAAnimation *drawAnimation = [self strokePathAnimationWithScoreEndValue:value];
    CAAnimation *colorAnimation = [self strokeColorAnimationWithScoreEndValue:value];
    [circle addAnimation:drawAnimation forKey:arcAnimationKey];
    [circle addAnimation:colorAnimation forKey:colorAnimationKey];
    [self.layer addSublayer:circle];
    [self animateScoreLabelTo:value];
}

- (CAAnimation *)strokePathAnimationWithScoreEndValue:(CGFloat)value {
    CABasicAnimation *drawAnimation =
        [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    drawAnimation.duration = HEMSleepScoreAnimationDuration;
    drawAnimation.repeatCount = 1.0;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0];
    drawAnimation.toValue = [NSNumber numberWithFloat:1.f];
    drawAnimation.fillMode = kCAFillModeForwards;
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return drawAnimation;
}

- (CAAnimation *)strokeColorAnimationWithScoreEndValue:(CGFloat)value {
    CGColorRef alertColor = [UIColor colorForCondition:SENConditionAlert].CGColor;
    CGColorRef warningColor = [UIColor colorForCondition:SENConditionWarning].CGColor;
    CGColorRef idealColor = [UIColor colorForCondition:SENConditionIdeal].CGColor;
    NSMutableArray *values = [NSMutableArray arrayWithObjects:(__bridge id)alertColor, nil];
    CGColorRef targetColor = [UIColor colorForCondition:self.condition].CGColor;
    BOOL targetIsAlert = CGColorEqualToColor(targetColor, alertColor);
    if (!targetIsAlert) {
        [values addObject:(__bridge id)warningColor];
    }
    if (!CGColorEqualToColor(targetColor, warningColor) && !targetIsAlert) {
        [values addObject:(__bridge id)idealColor];
    }
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeColor"];
    animation.values = values;
    animation.duration = HEMSleepScoreAnimationDuration;
    animation.repeatCount = 1.f;
    animation.removedOnCompletion = NO;
    animation.calculationMode = kCAAnimationCubicPaced;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}

- (void)animateScoreLabelTo:(CGFloat)value {
    self.scoreValueLabel.textColor = [UIColor colorForCondition:SENConditionAlert];
    self.scoreValueLabel.alpha = 1.f;
    UIColor *targetColor = [UIColor colorForCondition:self.condition];
    UIColor *idealColor = [UIColor colorForCondition:SENConditionIdeal];
    UIColor *warnColor = [UIColor colorForCondition:SENConditionWarning];
    if (![targetColor isEqual:self.scoreValueLabel.textColor]) {
        int64_t delay = (int64_t)((HEMSleepScoreAnimationDuration / 3) * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
          __strong typeof(weakSelf) strongSelf = weakSelf;
          strongSelf.scoreValueLabel.textColor = warnColor;
          if (![targetColor isEqual:warnColor]) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
                strongSelf.scoreValueLabel.textColor = idealColor;
              });
          }
        });
    }
    [self.scoreValueLabel countFrom:1 to:value];
}

- (void)setScore:(NSInteger)sleepScore condition:(SENCondition)condition animated:(BOOL)animated {
    if (sleepScore == _sleepScore)
        return;

    _condition = condition;
    _sleepScore = sleepScore;
    if (animated)
        [self animateScoreTo:sleepScore];
    self.accessibilityValue = [NSString stringWithFormat:NSLocalizedString(@"timeline.accessibility-value.summary-score.format", nil), (long)self.sleepScore, SENConditionReadableValue(self.condition)];
}

#pragma mark - Loading

- (BOOL)isLoading {
    return [self.loadingLayer animationForKey:scoreLoadingAnimation] != nil;
}

- (void)setLoading:(BOOL)loading {
    if (loading) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(opacity))];
        animation.autoreverses = YES;
        animation.repeatDuration = HUGE_VALF;
        animation.duration = 0.65f;
        animation.fromValue = @0;
        animation.toValue = @1;
        [self.loadingLayer addAnimation:animation forKey:scoreLoadingAnimation];
    } else {
        [self.loadingLayer removeAnimationForKey:scoreLoadingAnimation];
        [UIView animateWithDuration:0.2f
                         animations:^{
                           self.loadingLayer.opacity = 0;
                         }];
    }
}

@end
