
#import <UIKit/UIKit.h>

@class HEMSimpleLineTextField;

@protocol HEMSimpleLineTextFieldDelegate <NSObject>

- (void)textField:(HEMSimpleLineTextField*)textField didGainFocus:(BOOL)focus;

@end

@interface HEMSimpleLineTextField : UITextField

@property (nonatomic, strong, readonly) UIButton* revealSecretButton;
@property (nonatomic, assign, getter=isSecurityEnabled) BOOL securityEnabled;

@property (nonatomic, weak) id<HEMSimpleLineTextFieldDelegate> textFieldDelegate;

@end
