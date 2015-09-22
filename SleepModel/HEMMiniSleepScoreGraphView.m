
#import "HEMMiniSleepScoreGraphView.h"
#import "HelloStyleKit.h"
#import "UIColor+HEMStyle.h"
#import "NSString+HEMUtils.h"

@implementation HEMMiniSleepScoreGraphView

CGFloat const miniScoreBaseHeight = 72.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [self drawMiniSleepScoreGraphWithSleepScore:self.sleepScore sleepScoreHeight:miniScoreBaseHeight];
}

- (void)setSleepScore:(NSUInteger)sleepScore
{
    _sleepScore = sleepScore;
    [self setNeedsDisplay];
}

- (void)drawMiniSleepScoreGraphWithSleepScore:(CGFloat)sleepScore sleepScoreHeight:(CGFloat)sleepScoreHeight
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Color Declarations
    UIColor* sleepScoreNoValueColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.059];
    UIColor* sleepScoreOvalColor = [UIColor colorWithRed: 0.898 green: 0.898 blue: 0.898 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore > 0 ? (sleepScore < 45 ? HelloStyleKit.alertSensorColor : (sleepScore < 80 ? HelloStyleKit.warningSensorColor : HelloStyleKit.idealSensorColor)) : sleepScoreNoValueColor;
    CGFloat graphPercentageAngle = MAX(MIN(sleepScore > 0 ? (sleepScore < 100 ? 400 - sleepScore * 0.01 * 300 : 0.01) : 0.01, 359), 102);
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (long)round(sleepScore)] : @"100") : @"";
    CGFloat sleepScoreTextSize = sleepScoreHeight / 2.0;

    //// background oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 11.5, 5.5);
    CGContextRotateCTM(context, 141 * M_PI / 180);

    CGRect backgroundOvalRect = CGRectMake(-36.74, -77, sleepScoreHeight, sleepScoreHeight);
    UIBezierPath* backgroundOvalPath = UIBezierPath.bezierPath;
    [backgroundOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(backgroundOvalRect), CGRectGetMidY(backgroundOvalRect)) radius: CGRectGetWidth(backgroundOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -102 * M_PI/180 clockwise: YES];

    [sleepScoreOvalColor setStroke];
    backgroundOvalPath.lineWidth = 1;
    [backgroundOvalPath stroke];

    CGContextRestoreGState(context);


    //// pie oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 11.5, 5.5);
    CGContextRotateCTM(context, 141 * M_PI / 180);

    CGRect pieOvalRect = CGRectMake(-36.74, -77.01, sleepScoreHeight, sleepScoreHeight);
    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter: CGPointMake(CGRectGetMidX(pieOvalRect), CGRectGetMidY(pieOvalRect)) radius: CGRectGetWidth(pieOvalRect) / 2 startAngle: 0 * M_PI/180 endAngle: -graphPercentageAngle * M_PI/180 clockwise: YES];

    [sleepScoreColor setStroke];
    pieOvalPath.lineWidth = 1;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// sleep score label Drawing
    CGRect sleepScoreLabelRect = CGRectMake(-1, 5.67, 77, 67.53);
    NSMutableParagraphStyle* sleepScoreLabelStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    sleepScoreLabelStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* sleepScoreLabelFontAttributes = @{
        NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-UltraLight" size: sleepScoreTextSize],
        NSForegroundColorAttributeName: sleepScoreColor,
        NSParagraphStyleAttributeName: sleepScoreLabelStyle};

    CGFloat sleepScoreLabelTextHeight = [sleepScoreText heightBoundedByWidth:CGRectGetWidth(sleepScoreLabelRect)
                                                                  attributes:sleepScoreLabelFontAttributes];
    CGContextSaveGState(context);
    CGContextClipToRect(context, sleepScoreLabelRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(sleepScoreLabelRect), CGRectGetMinY(sleepScoreLabelRect) + (CGRectGetHeight(sleepScoreLabelRect) - sleepScoreLabelTextHeight) / 2, CGRectGetWidth(sleepScoreLabelRect), sleepScoreLabelTextHeight) withAttributes: sleepScoreLabelFontAttributes];
    CGContextRestoreGState(context);
}

@end
