
#import "HEMSleepSegmentCollectionViewCell.h"
#import "UIFont+HEMStyle.h"
#import "HelloStyleKit.h"

CGFloat const HEMLinedCollectionViewCellLineOffset = 65.f;
CGFloat const HEMLinedCollectionViewCellLineWidth = 2.f;
CGFloat const HEMSleepLineWidth = 1.f;

@interface HEMSleepSegmentCollectionViewCell ()

@property (nonatomic, readwrite) CGFloat fillRatio;
@property (nonatomic, strong, readwrite) UIColor* fillColor;
@property (nonatomic, strong, readwrite) UIColor* lineColor;
@property (nonatomic, strong) NSMutableArray* timeViews;
@end

@implementation HEMSleepSegmentCollectionViewCell

static CGFloat const HEMSegmentTimeLabelHeight = 16.f;
static CGFloat const HEMSegmentTimeLabelVerticalSpacing = 2.f;
static CGFloat const HEMSegmentTimeLabelHorizontalSpacing = 10.f;
static CGFloat const HEMSegmentBorderWidth = 1.f;
static CGFloat const HEMSegmentBorderDashLength[] = {4,4};
static int const HEMNoSleepBorderDashLengthCount = 2;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    self.timeViews = [NSMutableArray new];
}

- (void)removeAllTimeLabels
{
    [self.timeViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.timeViews removeAllObjects];
}

- (void)addTimeLabelWithText:(NSString*)text atHeightRatio:(CGFloat)heightRatio
{
    CGFloat lineYOffset = CGRectGetHeight(self.bounds) * heightRatio;
    CGFloat labelYOffset = lineYOffset - HEMSegmentTimeLabelHeight - HEMSegmentTimeLabelVerticalSpacing;
    CGFloat width = CGRectGetWidth(self.bounds)/2;
    CGRect labelRect = CGRectMake(HEMSegmentTimeLabelHorizontalSpacing, labelYOffset, width, HEMSegmentTimeLabelHeight);
    CGRect lineRect = CGRectMake(0, lineYOffset, width, HEMSegmentBorderWidth);
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:labelRect];
    timeLabel.text = text;
    timeLabel.font = [UIFont timelineEventTimestampFont];
    timeLabel.textColor = [UIColor colorWithWhite:0 alpha:0.25f];
    [timeLabel sizeToFit];
    [self insertSubview:timeLabel atIndex:0];
    UIImageView* lineView = [[UIImageView alloc] initWithFrame:lineRect];
    lineView.image = [self dottedLineBorderImageWithColor:[UIColor colorWithWhite:0 alpha:0.15f] useMask:YES];
    [self insertSubview:lineView atIndex:0];
    [self.timeViews addObject:lineView];
    [self.timeViews addObject:timeLabel];
}

- (UIImage*)maskImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    NSArray *colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor whiteColor].CGColor];
    CGFloat locations[] = {0,1};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, locations);
    CGColorSpaceRelease(space);
    CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(size.width, 0), 0);
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mask;
}

- (UIImage*)dottedLineBorderImageWithColor:(UIColor*)color
{
    return [self dottedLineBorderImageWithColor:color useMask:NO];
}

- (UIImage*)dottedLineBorderImageWithColor:(UIColor*)color useMask:(BOOL)useMask
{
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds)/2, HEMSegmentBorderWidth);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, HEMSegmentBorderWidth);
    CGContextSetLineDash(ctx, 0, HEMSegmentBorderDashLength, HEMNoSleepBorderDashLengthCount);
    CGFloat y = size.height - HEMSegmentBorderWidth;
    CGContextMoveToPoint(ctx, 0, y);
    CGContextAddLineToPoint(ctx, size.width, y);
    CGContextStrokePath(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (useMask) {
        CGImageRef mask = [self maskImageWithSize:size].CGImage;
        CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(mask),
                                                 CGImageGetHeight(mask),
                                                 CGImageGetBitsPerComponent(mask),
                                                 CGImageGetBitsPerPixel(mask),
                                                 CGImageGetBytesPerRow(mask),
                                                 CGImageGetDataProvider(mask),
                                                 NULL,
                                                 YES);
        CGImageRef maskedImage = CGImageCreateWithMask(image.CGImage, imageMask);
        CGImageRelease(imageMask);
        return [UIImage imageWithCGImage:maskedImage];
    } else {
        return image;
    }

}

- (void)setSegmentRatio:(CGFloat)ratio withFillColor:(UIColor *)color lineColor:(UIColor *)lineColor
{
    self.fillRatio = MIN(ratio, 1.0);
    self.fillColor = color;
    self.lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (![self isLastSegment] && ![self isFirstSegment]) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGFloat inset = HEMLinedCollectionViewCellLineOffset + HEMLinedCollectionViewCellLineWidth;
        CGFloat maximumFillWidth = (CGRectGetWidth(rect) - (inset*2));
        CGFloat width = maximumFillWidth * self.fillRatio;
        CGFloat x = (CGRectGetWidth(rect) - width)/2;
        CGRect fillRect = CGRectMake(x, CGRectGetMinY(rect), width, CGRectGetHeight(rect));
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        CGContextFillRect(ctx, fillRect);
    }
}

@end
