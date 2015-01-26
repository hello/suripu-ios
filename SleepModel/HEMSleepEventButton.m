
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
    self.layer.shadowColor = [HelloStyleKit tintColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOpacity = 0.4f;
    self.layer.borderColor = [[HelloStyleKit tintColor] colorWithAlphaComponent:0.2f].CGColor;
    self.layer.borderWidth = 0.5f;
}

- (void)hideOutline
{
    self.layer.shadowRadius = 2.f;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeMake(0, -4);
    self.layer.borderWidth = 0;
}

@end
