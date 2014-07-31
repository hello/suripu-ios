#import <stdlib.h>
#import "HEMMiniSleepScoreGraphView.h"
#import "HelloStyleKit.h"

@interface HEMMiniSleepScoreGraphView ()
@property (nonatomic) NSInteger sleepScore;
@end

@implementation HEMMiniSleepScoreGraphView

- (void)awakeFromNib
{
    self.sleepScore = arc4random() % 100;
}

- (void)drawRect:(CGRect)rect
{
    [HelloStyleKit drawMiniSleepScoreGraphWithSleepScore:self.sleepScore];
}

@end
