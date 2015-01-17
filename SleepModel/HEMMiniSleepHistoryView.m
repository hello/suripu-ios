
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

static CGFloat const HEMMiniSleepBandWidth = 1.f;

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
    CGFloat startYOffset = CGRectGetMinY(rect);
    for (SENSleepResultSegment* segment in self.sleepDataSegments) {
        NSTimeInterval duration = [self durationForSegment:segment];
        CGFloat endYOffset = startYOffset + (duration/self.secondsPerPoint);
        CGFloat endXOffset = [self xOffsetForSleepDepth:segment.sleepDepth];
        CGContextSetFillColorWithColor(ctx, [UIColor colorForSleepDepth:segment.sleepDepth].CGColor);
        CGRect fillRect = CGRectMake(CGRectGetMinX(rect) + (CGRectGetWidth(rect) - endXOffset)/2, startYOffset, endXOffset, endYOffset - startYOffset);
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
