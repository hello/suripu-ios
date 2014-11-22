
#import "HEMMiniSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@implementation HEMMiniSleepScoreGraphView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

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
