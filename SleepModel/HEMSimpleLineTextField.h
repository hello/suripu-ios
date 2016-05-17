
#import <UIKit/UIKit.h>

@class HEMSimpleLineTextField;

@protocol HEMSimpleLineTextFieldDelegate <NSObject>

- (void)textField:(HEMSimpleLineTextField*)textField didGainFocus:(BOOL)focus;

@end

@interface HEMSimpleLineTextField : UITextField

@property (nonatomic, weak) id<HEMSimpleLineTextFieldDelegate> textFieldDelegate;

@end
