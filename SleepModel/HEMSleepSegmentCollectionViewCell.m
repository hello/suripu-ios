
#import "HEMSleepSegmentCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 65.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepLineWidth = 1.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, strong, readwrite) UIColor *fillColor;
@property (nonatomic, strong, readwrite) UIColor *lineColor;
@property (nonatomic, strong) NSMutableArray *timeViews;
@property (nonatomic) BOOL shouldEmphasize;
@end

@implementation HEMSleepSegmentCollectionViewCell

static CGFloat const HEMSegmentTimeLabelHeight = 16.f;
static CGFloat const HEMSegmentBorderWidth = 1.f;

- (void)awakeFromNib {
    self.backgroundColor = [UIColor clearColor];
    self.timeViews = [NSMutableArray new];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.shouldEmphasize = NO;
}

- (void)emphasizeAppearance {
    self.shouldEmphasize = YES;
    [self setNeedsDisplay];
}

- (void)deemphasizeAppearance {
    self.shouldEmphasize = NO;
    [self setNeedsDisplay];
}

- (void)removeAllTimeLabels {
    [self.timeViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.timeViews removeAllObjects];
}

- (NSUInteger)numberOfTimeLabels {
    return self.timeViews.count;
}

- (void)addTimeLabelWithText:(NSString *)text atHeightRatio:(CGFloat)heightRatio {
    static CGFloat const HEMTimeLabelLineOffset = 8.f;
    static CGFloat const HEMTimeLabelWidth = 32.f;
    self.clipsToBounds = NO;
    CGFloat textInset = HEMTimeLabelLineOffset * 2 + HEMTimeLabelWidth;
    CGFloat lineYOffset = MIN(CGRectGetHeight(self.bounds) * heightRatio,
                              CGRectGetHeight(self.frame) - ceilf(HEMSegmentTimeLabelHeight / 2));
    CGFloat labelYOffset = lineYOffset - floorf(HEMSegmentTimeLabelHeight / 2);
    CGFloat width = CGRectGetWidth(self.bounds) - textInset;
    CGRect labelRect = CGRectMake(CGRectGetWidth(self.bounds) - HEMTimeLabelWidth - HEMTimeLabelLineOffset,
                                  labelYOffset, HEMTimeLabelWidth, HEMSegmentTimeLabelHeight);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:labelRect];
    timeLabel.text = text;
    timeLabel.font = [UIFont timelineEventTimestampFont];
    timeLabel.textColor = [HelloStyleKit tintColor];
    [timeLabel sizeToFit];
    [self insertSubview:timeLabel atIndex:0];
    CGRect lineRect = CGRectMake(0, lineYOffset, width, HEMSegmentBorderWidth);
    UIImageView *lineView = [[UIImageView alloc] initWithFrame:lineRect];
    lineView.image = [self lineBorderImageWithColor:[[HelloStyleKit tintColor] colorWithAlphaComponent:0.15f]];
    [self insertSubview:lineView atIndex:0];
    [self.timeViews addObject:lineView];
    [self.timeViews addObject:timeLabel];
}

- (UIImage *)lineBorderImageWithColor:(UIColor *)color {
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) / 2, HEMSegmentBorderWidth);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, HEMSegmentBorderWidth);
    CGFloat y = size.height - HEMSegmentBorderWidth;
    CGContextMoveToPoint(ctx, 0, y);
    CGContextAddLineToPoint(ctx, size.width, y);
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setSegmentRatio:(CGFloat)ratio withFillColor:(UIColor *)color lineColor:(UIColor *)lineColor {
    self.fillRatio = MIN(ratio, 1.0);
    self.fillColor = color;
    self.lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    static CGFloat const HEMSegmentMinimumWidth = 32.f;
    static CGFloat const HEMSegmentMaximumWidthRatio = 0.825f;
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat maximumFillWidth = CGRectGetWidth(rect) * HEMSegmentMaximumWidthRatio;
    CGFloat width = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.fillRatio);
    CGRect fillRect = CGRectMake(0, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, fillRect);
    if ([self shouldEmphasize]) {
        CGContextSetStrokeColorWithColor(ctx, [HelloStyleKit tintColor].CGColor);
        CGContextSetLineWidth(ctx, HEMSegmentBorderWidth);
        CGContextStrokeRect(ctx, fillRect);
    }
}

@end
