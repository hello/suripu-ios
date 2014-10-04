
#import "HEMSleepEventButton.h"

@implementation HEMSleepEventButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2;
        self.layer.borderWidth = 2.f;
    }
    return self;
}

@end
