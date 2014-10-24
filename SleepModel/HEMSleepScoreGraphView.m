
#import "HEMSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMSleepScoreGraphView ()

@property (nonatomic) NSInteger sleepScore;
@property (nonatomic) NSInteger targetSleepScore;
@property (nonatomic, strong) NSString* sleepScoreLabelText;
@property (nonatomic, strong) NSString* sleepScoreDateText;
@end

@implementation HEMSleepScoreGraphView

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _sleepScoreLabelText = NSLocalizedString(@"sleep-history.score", nil);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [HelloStyleKit drawSleepScoreGraphWithSleepScoreLabelText:self.sleepScoreLabelText sleepScore:self.sleepScore];
}

- (void)animateScoreTo:(CGFloat)value
{
    for (int i = 0; i < value; i++) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * 0.0075 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _sleepScore = i + 1;
            [self setNeedsDisplay];
        });
    }
}

- (void)setSleepScore:(NSInteger)sleepScore animated:(BOOL)animated
{
    if (sleepScore == _sleepScore || self.targetSleepScore == sleepScore)
        return;

    if (animated) {
        self.targetSleepScore = sleepScore;
        [self animateScoreTo:sleepScore];
    }
    else {
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

- (void)setSleepScoreLabelText:(NSString*)sleepScoreLabelText
{
    if ([sleepScoreLabelText isEqualToString:_sleepScoreLabelText])
        return;

    _sleepScoreLabelText = sleepScoreLabelText;
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
