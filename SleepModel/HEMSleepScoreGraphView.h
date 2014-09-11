
#import <UIKit/UIKit.h>

@interface HEMSleepScoreGraphView : UIView

- (void)setSleepScore:(NSInteger)sleepScore;
- (void)setSleepScore:(NSInteger)sleepScore animated:(BOOL)animated;
- (void)setSleepScoreLabelText:(NSString*)sleepScoreLabelText;
- (void)setSleepScoreDateText:(NSString*)sleepScoreDateText;
@end
