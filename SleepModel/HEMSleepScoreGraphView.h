
#import <UIKit/UIKit.h>

@interface HEMSleepScoreGraphView : UIView

- (void)setSleepScore:(NSInteger)sleepScore animated:(BOOL)animated;
- (BOOL)isLoading;
- (void)setLoading:(BOOL)loading;
@end
