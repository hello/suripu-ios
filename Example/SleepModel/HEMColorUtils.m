
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@implementation HEMColorUtils

+ (CAGradientLayer*)layerWithBlueBackgroundGradientInFrame:(CGRect)frame
{
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = @[ (id)[[HelloStyleKit darkBlueColor] CGColor],
                         (id)[[HelloStyleKit mediumBlueColor] CGColor],
                         (id)[[HelloStyleKit darkBlueColor] CGColor] ];
    gradient.locations = @[ @0, @1, @1 ];
    return gradient;
}
@end
