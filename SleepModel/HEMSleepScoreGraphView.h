
#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>

@interface HEMSleepScoreGraphView : UIView

- (void)setScore:(NSInteger)sleepScore condition:(SENCondition)condition animated:(BOOL)animated;
- (BOOL)isLoading;
- (void)setLoading:(BOOL)loading;
@end
