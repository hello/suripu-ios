
#import <UIKit/UIKit.h>

@class HEMSimpleLineTextField;

@protocol HEMTextFieldFocusDelegate <NSObject>

- (void)textField:(HEMSimpleLineTextField*)textField didGainFocus:(BOOL)focus;
- (void)textField:(HEMSimpleLineTextField *)textField didChange:(NSString*)text;

@end

@interface HEMSimpleLineTextField : UITextField

@property (nonatomic, strong, readonly) UIButton* revealSecretButton;
@property (nonatomic, assign, getter=isSecurityEnabled) BOOL securityEnabled;
@property (nonatomic, strong) UIColor* focusedPlaceholderColor;
@property (nonatomic, strong) UIColor* placeholderColor;

@property (nonatomic, weak) id<HEMTextFieldFocusDelegate> focusDelegate;
    
- (void)applyStyle;

@end
