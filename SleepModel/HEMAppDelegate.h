
#import <UIKit/UIKit.h>

@interface HEMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;

- (void)openSettingsDrawer;
- (void)closeSettingsDrawer;
- (void)toggleSettingsDrawer;
@end
