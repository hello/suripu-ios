
#import <SenseKit/SENSettings.h>

#import "HEMMiniSleepHistoryView.h"
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@interface HEMMiniSleepHistoryView ()

@property (nonatomic) NSTimeInterval startInterval;
@property (nonatomic) NSTimeInterval endInterval;
@property (nonatomic) NSTimeInterval secondsPerPoint;
@property (nonatomic, strong) NSArray* sleepEvents;
@end

@implementation HEMMiniSleepHistoryView

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
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, rect);
    for (NSDictionary* segment in self.sleepDataSegments) {
        NSTimeInterval sliceStartInterval = [self timeIntervalForSegment:segment];
        NSTimeInterval sliceEndInterval = sliceStartInterval + [self durationForSegment:segment];
        CGFloat startYOffset = [self yOffsetForTimeInterval:sliceStartInterval];
        CGFloat endYOffset = [self yOffsetForTimeInterval:sliceEndInterval];
        NSInteger sleepDepth = [segment[@"sleep_depth"] integerValue];
        CGFloat endXOffset = [self xOffsetForSleepDepth:sleepDepth];
        UIColor* color = [HEMColorUtils colorForSleepDepth:sleepDepth];
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, CGRectMake(CGRectGetMinX(rect), startYOffset, endXOffset, endYOffset - startYOffset));
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
    return (CGRectGetWidth(self.bounds) / 3) * sleepDepth;
}

#pragma mark - Data Parsing

- (NSTimeInterval)timeIntervalForSegment:(NSDictionary*)segment
{
    return [segment[@"timestamp"] doubleValue] / 1000;
}

- (NSTimeInterval)durationForSegment:(NSDictionary*)segment
{
    return [segment[@"duration"] doubleValue] / 1000;
}

- (NSDate*)dateFromTimeInterval:(NSTimeInterval)interval
{
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

@end
