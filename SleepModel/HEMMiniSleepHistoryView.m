
#import <SenseKit/SENTimeline.h>

#import "HEMMiniSleepHistoryView.h"
#import "UIColor+HEMStyle.h"

@interface HEMMiniSleepHistoryView ()
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* sleepEvents;
@end

@implementation HEMMiniSleepHistoryView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)reloadData
{
    SENTimelineSegment* earliestSegment = [self.sleepDataSegments firstObject];
    SENTimelineSegment* latestSegment = [self.sleepDataSegments lastObject];
    CGFloat duration = [self durationWithStartingSegment:earliestSegment endingSegment:latestSegment];
    if (duration < 0)
        duration = [self durationWithStartingSegment:latestSegment endingSegment:earliestSegment];
    self.secondsPerPoint = duration / (CGRectGetHeight(self.bounds)*1.5);
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
    CGFloat const minMiniSleepHeight = 4.f;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat startYOffset = CGRectGetMinY(rect);
    for (SENTimelineSegment* segment in self.sleepDataSegments) {
        NSTimeInterval duration = segment.duration;
        CGFloat endYOffset = startYOffset + MAX(duration/self.secondsPerPoint, minMiniSleepHeight);
        CGFloat endXOffset = [self xOffsetForSleepDepth:segment.sleepDepth];
        CGFloat height = endYOffset - startYOffset;
        CGContextSetFillColorWithColor(ctx, [UIColor colorForSleepState:segment.sleepState].CGColor);
        CGRect fillRect = CGRectMake(0, startYOffset, endXOffset, height);
        CGContextFillRect(ctx, fillRect);
        startYOffset = endYOffset;
    }
}

- (CGFloat)xOffsetForSleepDepth:(NSInteger)sleepDepth
{
    return CGRectGetWidth(self.bounds) * (sleepDepth * 0.01f);
}

#pragma mark - Data Parsing

- (CGFloat)durationWithStartingSegment:(SENTimelineSegment*)earliestSegment
                         endingSegment:(SENTimelineSegment*)latestSegment
{
    NSTimeInterval startInterval = [self timeIntervalForSegment:earliestSegment];
    NSTimeInterval endInterval = [self timeIntervalForSegment:latestSegment] + latestSegment.duration;
    return endInterval - startInterval;
}

- (NSTimeInterval)timeIntervalForSegment:(SENTimelineSegment*)segment
{
    return [segment.date timeIntervalSince1970];
}

@end
