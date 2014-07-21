
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

+ (void)configureLayer:(CAGradientLayer*)gradient
    withBlueBackgroundGradientInFrame:(CGRect)frame
                       intensityLevel:(CGFloat)level
{
    UIColor* topColor = [UIColor colorWithHue:0.611
                                   saturation:MIN(MAX(level * 0.7,0.15),1)
                                   brightness:MIN(MAX(level * 0.7,0.25),1)
                                        alpha:1.f];
    UIColor* bottomColor = [UIColor colorWithHue:0.546
                                      saturation:MIN(MAX(level * 1.2, 0.2),1)
                                      brightness:MIN(MAX(level * 1.2, 0.3),1)
                                           alpha:1.f];
    gradient.frame = frame;
    gradient.colors = @[ (id)[topColor CGColor],
                         (id)[bottomColor CGColor],
                         (id)[topColor CGColor] ];
    gradient.locations = @[ @0, @1, @1 ];
}

@end
