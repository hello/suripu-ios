
#import "HEMSleepEventButton.h"
#import "HelloStyleKit.h"

@implementation HEMSleepEventButton

- (void)awakeFromNib
{
    [self showOutline];
    self.layer.cornerRadius = CGRectGetWidth(self.bounds)/2;
}

- (void)showOutline
{
    self.layer.shadowColor = [HelloStyleKit barButtonEnabledColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOpacity = 0.4f;
    self.layer.borderColor = [[HelloStyleKit barButtonEnabledColor] colorWithAlphaComponent:0.2f].CGColor;
    self.layer.borderWidth = 1.f;
}

- (void)hideOutline
{
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeMake(0, -2);
    self.layer.borderWidth = 0;
}

@end
