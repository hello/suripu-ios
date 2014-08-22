
#import <UIKit/UIKit.h>

@interface HEMActionButton : UIButton

//
// Changes the button's shape to show an activity indicator
// while disabling the button
//
- (void)showActivity;

//
// If the button has been morphed and showing activity, this
// will return it back to normal
//
- (void)stopActivity;

@end
