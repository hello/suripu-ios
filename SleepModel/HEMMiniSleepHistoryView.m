
#import <SenseKit/SENSettings.h>
#import <SenseKit/SENSleepResult.h>

#import "HEMMiniSleepHistoryView.h"
#import "UIColor+HEMStyle.h"
#import "HelloStyleKit.h"

@interface HEMMiniSleepHistoryView ()
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* sleepEvents;
@end

@implementation HEMMiniSleepHistoryView

static CGFloat const HEMMiniSleepBandWidth = 1.f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)reloadData
{
    SENSleepResultSegment* earliestSegment = [self.sleepDataSegments firstObject];
    SENSleepResultSegment* latestSegment = [self.sleepDataSegments lastObject];
    CGFloat duration = [self durationWithStartingSegment:earliestSegment endingSegment:latestSegment];
    if (duration < 0)
        duration = [self durationWithStartingSegment:latestSegment endingSegment:earliestSegment];
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
    CGFloat startYOffset = CGRectGetMinY(rect);
    for (SENSleepResultSegment* segment in self.sleepDataSegments) {
        NSTimeInterval duration = [self durationForSegment:segment];
        CGFloat endYOffset = startYOffset + (duration/self.secondsPerPoint);
        CGFloat endXOffset = [self xOffsetForSleepDepth:segment.sleepDepth];
        CGFloat height = endYOffset - startYOffset;
        CGFloat startXOffset = CGRectGetMinX(rect) + (CGRectGetWidth(rect) - endXOffset)/2;
        CGContextSetFillColorWithColor(ctx, [UIColor colorForSleepDepth:segment.sleepDepth].CGColor);
        CGRect fillRect = CGRectMake(startXOffset, startYOffset, endXOffset, height);
        CGContextFillRect(ctx, fillRect);

        CGRect bandRect = fillRect;
        bandRect.size.width = HEMMiniSleepBandWidth;
        bandRect.origin.x = CGRectGetMidX(rect) - HEMMiniSleepBandWidth/2;
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        CGContextSetFillColorWithColor(ctx, [UIColor colorForSleepDepth:segment.sleepDepth].CGColor);
        CGContextFillRect(ctx, bandRect);
        startYOffset = endYOffset;
    }
}

- (CGFloat)xOffsetForSleepDepth:(NSInteger)sleepDepth
{
    return CGRectGetWidth(self.bounds) * (sleepDepth * 0.01f);
}

#pragma mark - Data Parsing

- (CGFloat)durationWithStartingSegment:(SENSleepResultSegment*)earliestSegment
                         endingSegment:(SENSleepResultSegment*)latestSegment
{
    NSTimeInterval startInterval = [self timeIntervalForSegment:earliestSegment];
    NSTimeInterval endInterval = [self timeIntervalForSegment:latestSegment] + [self durationForSegment:latestSegment];
    return endInterval - startInterval;
}

- (NSTimeInterval)timeIntervalForSegment:(SENSleepResultSegment*)segment
{
    return [segment.date timeIntervalSince1970];
}

- (NSTimeInterval)durationForSegment:(SENSleepResultSegment*)segment
{
    return [segment.duration doubleValue];
}

@end
