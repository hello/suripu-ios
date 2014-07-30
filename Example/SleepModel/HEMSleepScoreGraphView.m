
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepScoreGraphView ()

@property (nonatomic) NSInteger sleepScore;
@end

@implementation HEMSleepScoreGraphView

- (void)awakeFromNib
{
    [self animateScoreTo:90];
}

- (void)drawRect:(CGRect)rect
{
    [HelloStyleKit drawSleepScoreGraphWithSleepScoreLabelText:@"SLEEP SCORE" sleepScore:self.sleepScore];
}

- (void)animateScoreTo:(CGFloat)value
{
    for (int i = 0; i < value; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.0075 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ++self.sleepScore;
            [self setNeedsDisplay];
        });
    }
}

@end
