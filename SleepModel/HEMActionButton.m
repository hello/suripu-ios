
#import "HEMActionButton.h"
#import "HelloStyleKit.h"

@implementation HEMActionButton

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.layer.cornerRadius = 20.f;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [HelloStyleKit mediumBlueColor].CGColor;
        self.layer.borderWidth = 2.f;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.f]];
    }
    return self;
}

@end
