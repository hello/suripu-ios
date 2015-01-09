
#import "HEMMiniSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@implementation HEMMiniSleepScoreGraphView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [self drawMiniSleepScoreGraphWithSleepScore:self.sleepScore sleepScoreHeight:CGRectGetHeight(rect)];
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
    UIColor* sleepScoreTextColor = [UIColor colorWithRed: 0.3 green: 0.3 blue: 0.3 alpha: 1];

    //// Variable Declarations
    UIColor* sleepScoreColor = sleepScore > 0 ? (sleepScore < 45 ? [HelloStyleKit alertSensorColor] : (sleepScore < 80 ? [HelloStyleKit warningSensorColor] : [HelloStyleKit idealSensorColor])) : sleepScoreNoValueColor;
    CGFloat graphPercentageAngle = sleepScore > 0 ? (sleepScore < 100 ? 360 - sleepScore * 0.01 * 360 : 0.01) : 0.01;
    NSString* sleepScoreText = sleepScore > 0 ? (sleepScore <= 100 ? [NSString stringWithFormat: @"%ld", (NSInteger)round(sleepScore)] : @"100") : @"";
    CGFloat sleepScoreTextSize = sleepScoreHeight * 0.35;

    //// pie oval Drawing
    CGContextSaveGState(context);

    UIBezierPath* pieOvalPath = UIBezierPath.bezierPath;
    [pieOvalPath addArcWithCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
                           radius:CGRectGetWidth(self.bounds) / 2 - 8
                       startAngle:-90 * M_PI/180
                         endAngle:(-graphPercentageAngle - 90) * M_PI/180 clockwise:YES];

    [sleepScoreColor setStroke];
    pieOvalPath.lineWidth = 2.f;
    [pieOvalPath stroke];

    CGContextRestoreGState(context);


    //// Text Drawing
    CGRect textRect = CGRectMake(0, 0, sleepScoreHeight, sleepScoreHeight);
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;

    NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"AvenirNext-UltraLight" size: sleepScoreTextSize], NSForegroundColorAttributeName: sleepScoreTextColor, NSParagraphStyleAttributeName: textStyle};

    CGFloat textTextHeight = [sleepScoreText boundingRectWithSize: CGSizeMake(textRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes: textFontAttributes context: nil].size.height;
    CGContextSaveGState(context);
    CGContextClipToRect(context, textRect);
    [sleepScoreText drawInRect: CGRectMake(CGRectGetMinX(textRect), CGRectGetMinY(textRect) + (CGRectGetHeight(textRect) - textTextHeight) / 2, CGRectGetWidth(textRect), textTextHeight) withAttributes: textFontAttributes];
    CGContextRestoreGState(context);
}

@end
