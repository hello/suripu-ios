
#import <UIKit/UIKit.h>

@interface HEMSleepDataDetailView : UIView

- (void)setTimeLabelText:(NSString*)timeText;
- (void)setSleepDepthLabelText:(NSString*)sleepDepthText;
- (void)setEventWithTitle:(NSString*)title message:(NSString*)message;
- (void)setOffsetForArrow:(CGFloat)yOffset;
@end
