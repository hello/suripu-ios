
#import <UIKit/UIKit.h>
#import <SenseKit/SENCondition.h>
#import "HEMTappableView.h"

@interface HEMSleepScoreGraphView : HEMTappableView

- (void)setScore:(NSInteger)sleepScore condition:(SENCondition)condition animated:(BOOL)animated;
- (BOOL)isLoading;
- (void)setLoading:(BOOL)loading;
@end
