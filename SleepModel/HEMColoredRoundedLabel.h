
#import <UIKit/UIKit.h>

@interface HEMColoredRoundedLabel : UIView

- (void)hideRoundedBackground;
- (void)showRoundedBackground;

- (void)setText:(NSString*)text;
- (void)setTextColor:(UIColor*)textColor;
- (NSString*)text;
@end
