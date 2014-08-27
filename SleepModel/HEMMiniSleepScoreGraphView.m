
#import "HEMMiniSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@implementation HEMMiniSleepScoreGraphView

- (void)drawRect:(CGRect)rect
{
    [HelloStyleKit drawMiniSleepScoreGraphWithSleepScore:self.sleepScore];
}

- (void)setSleepScore:(NSUInteger)sleepScore
{
    _sleepScore = sleepScore;
    [self setNeedsDisplay];
}

@end
