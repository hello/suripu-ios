
#import "HEMSleepSegmentCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 65.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepLineWidth = 1.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, readwrite) CGFloat previousFillRatio;
@property (nonatomic, strong) NSMutableArray *timeViews;
@property (nonatomic, getter=isWaitingForAnimation, readwrite) BOOL waitingForAnimation;
@property (nonatomic, strong) CALayer *preFillLayer;
@property (nonatomic, strong) CALayer *fillLayer;
@end

@implementation HEMSleepSegmentCollectionViewCell

static CGFloat const HEMSegmentTimeLabelHeight = 16.f;
static CGFloat const HEMSegmentBorderWidth = 1.f;

- (void)awakeFromNib {
    self.opaque = YES;
    self.timeViews = [NSMutableArray new];
    self.fillLayer = [CALayer new];
    self.fillLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.preFillLayer = [CALayer new];
    self.preFillLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer insertSublayer:self.fillLayer atIndex:0];
    [self.layer insertSublayer:self.preFillLayer atIndex:0];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.clipsToBounds = YES;
    self.waitingForAnimation = NO;
    self.fillLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.fillLayer.frame = CGRectZero;
    self.preFillLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.preFillLayer.frame = CGRectZero;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateFillFrames];
}

- (void)prepareForEntryAnimation {
    self.waitingForAnimation = YES;
    [self updateFillFrames];
}

- (void)cancelEntryAnimation {
    self.waitingForAnimation = NO;
    [self updateFillFrames];
}

- (void)performEntryAnimationWithDuration:(NSTimeInterval)duration
                                    delay:(NSTimeInterval)delay
                               completion:(void (^)(BOOL))completion {
    self.waitingForAnimation = NO;
    [UIView animateWithDuration:duration
                          delay:delay
                        options:(UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseInOut)
                     animations:^{
                       [self updateFillFrames];
                     }
                     completion:completion];
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
    lineView.image = [self lineBorderImageWithColor:[[HelloStyleKit tintColor] colorWithAlphaComponent:0.25f]];
    [self addSubview:lineView];
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
    self.previousFillRatio = previousRatio;
    self.fillLayer.backgroundColor = color.CGColor;
    self.preFillLayer.backgroundColor = previousColor.CGColor;
    [self updateFillFrames];
}

- (void)updateFillFrames {
    CGFloat const HEMSegmentTimeInset = 12.f;
    CGFloat const HEMSegmentMinimumWidth = 32.f;
    CGFloat const HEMSegmentMaximumWidthRatio = 0.825f;
    CGRect rect = self.bounds;
    CGFloat maximumFillWidth = CGRectGetWidth(rect) * HEMSegmentMaximumWidthRatio;
    CGFloat preWidth = 0, width = 0;
    if (![self isWaitingForAnimation]) {
        preWidth = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.previousFillRatio);
        width = MAX(HEMSegmentMinimumWidth, maximumFillWidth * self.fillRatio);
    }
    CGRect preRect = CGRectMake(0, CGRectGetMinY(rect), preWidth, HEMSegmentTimeInset);
    CGRect fillRect
        = CGRectMake(0, CGRectGetMinY(rect) + HEMSegmentTimeInset, width, CGRectGetHeight(rect) - HEMSegmentTimeInset);
    self.fillLayer.frame = fillRect;
    self.preFillLayer.frame = preRect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, [HelloStyleKit timelineGradient].CGGradient, CGPointMake(CGRectGetMaxX(rect), 0),
                                CGPointZero, 0);
}

@end
