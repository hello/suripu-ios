
#import "HEMActionButton.h"
#import "HelloStyleKit.h"

@implementation HEMActionButton

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 20.f;
        self.backgroundColor = [HelloStyleKit mediumBlueColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

@end
