
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepScoreGraphView ()

@property (nonatomic) NSInteger sleepScore;
@property (nonatomic) NSInteger targetSleepScore;
@property (nonatomic, strong) NSString* sleepScoreDateText;
@end

@implementation HEMSleepScoreGraphView

static CGFloat const HEMSleepScoreFrameRatio = 0.014f;
static CGFloat const HEMSleepScoreAnimationDuration = 0.3f;
static CGFloat const HEMSleepScoreAnimationDelay = 0.35f;

- (void)awakeFromNib
{
    self.layer.contentsScale = 1.f;
}

- (void)drawRect:(CGRect)rect
{
    [HelloStyleKit drawSleepScoreGraphWithSleepScore:self.sleepScore];
}

- (void)animateScoreTo:(CGFloat)value
{
    if (value == 0)
        return;
    CGFloat frameDuration = HEMSleepScoreAnimationDuration/(value/2);
    int64_t delay = HEMSleepScoreAnimationDelay * NSEC_PER_SEC;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), ^{
        for (int i = 0; i < value; i += 2) {
            [self addAnimationFrameToValue:MIN(i + 2, value) frameDuration:frameDuration];
        }
    });
}

- (void)addAnimationFrameToValue:(CGFloat)value frameDuration:(CGFloat)seconds
{
    int64_t after = value * HEMSleepScoreFrameRatio * NSEC_PER_SEC;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after), dispatch_get_main_queue(), ^{
        _sleepScore = value;
        [self setNeedsDisplay];
    });
}

- (void)setSleepScore:(NSInteger)sleepScore animated:(BOOL)animated
{
    if (sleepScore == _sleepScore || (self.targetSleepScore == sleepScore && sleepScore != 0))
        return;

    if (sleepScore == 0) {
        self.sleepScore = sleepScore;
    } else if (animated) {
        self.targetSleepScore = sleepScore;
        [self animateScoreTo:sleepScore];
    } else {
        self.sleepScore = sleepScore;
    }
}

- (void)setSleepScore:(NSInteger)sleepScore
{
    if (sleepScore == _sleepScore)
        return;

    self.targetSleepScore = sleepScore;
    _sleepScore = sleepScore;
    [self setNeedsDisplay];
}

- (void)setSleepScoreDateText:(NSString*)sleepScoreDateText
{
    if ([sleepScoreDateText isEqualToString:_sleepScoreDateText])
        return;

    _sleepScoreDateText = sleepScoreDateText;
    [self setNeedsDisplay];
}

@end
