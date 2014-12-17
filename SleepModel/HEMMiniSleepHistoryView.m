
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSleepResult.h>

#import "HEMMiniSleepHistoryView.h"
#import "UIColor+HEMStyle.h"
#import "HelloStyleKit.h"

@interface HEMMiniSleepHistoryView ()

@property (nonatomic) NSTimeInterval startInterval;
@property (nonatomic) NSTimeInterval endInterval;
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* sleepEvents;
@end

@implementation HEMMiniSleepHistoryView

static CGFloat const HEMMiniSleepBandWidth = 2.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)reloadData
{
    self.startInterval = [self timeIntervalForSegment:[self.sleepDataSegments lastObject]];
    self.endInterval = [self timeIntervalForSegment:[self.sleepDataSegments firstObject]]
                       + [self durationForSegment:[self.sleepDataSegments firstObject]];
    CGFloat duration = self.endInterval - self.startInterval;
    self.secondsPerPoint = duration / CGRectGetHeight(self.bounds);
    [self setNeedsDisplay];
}

- (void)setSleepDataSegments:(NSArray*)sleepDataSegments
{
    _sleepDataSegments = sleepDataSegments;
    [self reloadData];
}

#pragma mark - Custom Drawing

- (void)drawRect:(CGRect)rect
{
    [self drawSleepDepthInRect:rect];
}

- (void)drawSleepDepthInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (SENSleepResultSegment* segment in self.sleepDataSegments) {
        NSTimeInterval sliceStartInterval = [self timeIntervalForSegment:segment];
        NSTimeInterval sliceEndInterval = sliceStartInterval + [self durationForSegment:segment];
        CGFloat startYOffset = floorf([self yOffsetForTimeInterval:sliceStartInterval]);
        CGFloat endYOffset = floorf([self yOffsetForTimeInterval:sliceEndInterval]);
        CGFloat endXOffset = [self xOffsetForSleepDepth:segment.sleepDepth];
        CGContextSetFillColorWithColor(ctx, [self colorForSegment:segment].CGColor);
        CGRect fillRect = CGRectMake(CGRectGetMinX(rect), startYOffset, endXOffset, endYOffset - startYOffset);
        CGContextFillRect(ctx, fillRect);

        fillRect.size.width = HEMMiniSleepBandWidth;
        CGContextSetFillColorWithColor(ctx, [UIColor colorForSleepDepth:segment.sleepDepth].CGColor);
        CGContextFillRect(ctx, fillRect);
    }
}

- (CGFloat)yOffsetForTimeInterval:(NSTimeInterval)interval
{
    return (interval - self.startInterval) / self.secondsPerPoint;
}

- (CGPoint)locationForDataAtTimeInterval:(NSTimeInterval)interval
{
    return CGPointMake(0, [self yOffsetForTimeInterval:interval]);
}

- (CGFloat)xOffsetForSleepDepth:(NSInteger)sleepDepth
{
    return CGRectGetWidth(self.bounds) * (sleepDepth * 0.01f);
}

#pragma mark - Data Parsing

- (UIColor*)colorForSegment:(SENSleepResultSegment*)segment
{
    CGFloat sleepDepth = segment.sleepDepth;
    if (sleepDepth == 0)
        return [UIColor clearColor];
    else if (sleepDepth == 100)
        return [UIColor colorWithHue:0.6 saturation:0.81 brightness:0.85 alpha:1];
    else if (sleepDepth < 60)
        return [UIColor colorWithHue:0.56 saturation:0.15 brightness:0.95 alpha:1];
    else
        return [UIColor colorWithHue:0.58 saturation:0.29 brightness:0.95 alpha:1];
}

- (NSTimeInterval)timeIntervalForSegment:(SENSleepResultSegment*)segment
{
    return [segment.date timeIntervalSince1970];
}

- (NSTimeInterval)durationForSegment:(SENSleepResultSegment*)segment
{
    return [segment.duration doubleValue];
}

- (NSDate*)dateFromTimeInterval:(NSTimeInterval)interval
{
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

@end
