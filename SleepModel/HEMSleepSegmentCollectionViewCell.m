
#import "HEMSleepSegmentCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 65.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepLineWidth = 1.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, readwrite) CGFloat previousFillRatio;
@property (nonatomic, strong, readwrite) UIColor *previousFillColor;
@property (nonatomic, strong, readwrite) UIColor *fillColor;
@property (nonatomic, strong) NSMutableArray *timeViews;
@property (nonatomic) BOOL shouldEmphasize;
@end

@implementation HEMSleepSegmentCollectionViewCell

static CGFloat const HEMSegmentTimeLabelHeight = 16.f;
static CGFloat const HEMSegmentBorderWidth = 1.f;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        self.previousFillColor = [UIColor clearColor];
        self.opaque = NO;
        self.timeViews = [NSMutableArray new];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.shouldEmphasize = NO;
    self.clipsToBounds = YES;
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

- (void)addTimeLabelWithText:(NSAttributedString *)text atHeightRatio:(CGFloat)heightRatio {
    static CGFloat const HEMTimeLabelLineOffset = 8.f;
    static CGFloat const HEMTimeLabelWidth = 30.f;
    CGFloat textInset = HEMTimeLabelLineOffset * 2 + HEMTimeLabelWidth;
    self.clipsToBounds = NO;
    CGFloat lineYOffset = MIN(CGRectGetHeight(self.bounds) * heightRatio,
                              MAX(0, CGRectGetHeight(self.frame) - HEMSegmentTimeLabelHeight));
    CGFloat labelYOffset = lineYOffset - floorf(HEMSegmentTimeLabelHeight / 2);
    CGFloat width = CGRectGetWidth(self.bounds) - textInset;
    CGRect labelRect = CGRectMake(CGRectGetWidth(self.bounds) - HEMTimeLabelWidth, labelYOffset, HEMTimeLabelWidth,
                                  HEMSegmentTimeLabelHeight);
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:labelRect];
    timeLabel.attributedText = text;
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

- (void)setSegmentRatio:(CGFloat)ratio
          withFillColor:(UIColor *)color
          previousRatio:(CGFloat)previousRatio
          previousColor:(UIColor *)previousColor {
    self.fillRatio = MIN(ratio, 1.0);
    self.fillColor = color;
    self.previousFillColor = previousColor;
    self.previousFillRatio = previousRatio;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGFloat const HEMSegmentTimeInset = 12.f;
    CGFloat const HEMSegmentMinimumWidth = 32.f;
    CGFloat const HEMSegmentMaximumWidthRatio = 0.825f;
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat maximumFillWidth = CGRectGetWidth(rect) * HEMSegmentMaximumWidthRatio;
    CGFloat preWidth = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.previousFillRatio);
    CGFloat width = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.fillRatio);
    CGRect preRect = CGRectMake(0, CGRectGetMinY(rect), preWidth, HEMSegmentTimeInset);
    CGRect fillRect
        = CGRectMake(0, CGRectGetMinY(rect) + HEMSegmentTimeInset, width, CGRectGetHeight(rect) - HEMSegmentTimeInset);
    CGContextSetFillColorWithColor(ctx, self.previousFillColor.CGColor);
    CGContextFillRect(ctx, preRect);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, fillRect);
    if ([self shouldEmphasize]) {
        CGContextSetStrokeColorWithColor(ctx, [HelloStyleKit tintColor].CGColor);
        CGContextSetLineWidth(ctx, HEMSegmentBorderWidth);
        CGContextStrokeRect(ctx, fillRect);
    }
}

@end
