
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@implementation HEMColorUtils

+ (void)configureLayer:(CAGradientLayer*)gradient
    withIntensityLevel:(CGFloat)level
{
    UIColor* topColor = [UIColor colorWithHue:0.658
                                   saturation:MIN(MAX(level * 0.4, 0.15), 1)
                                   brightness:MIN(MAX(level * 0.5, 0.25), 1)
                                        alpha:1.f];
    UIColor* bottomColor = [UIColor colorWithHue:0.567
                                      saturation:MIN(MAX(level * 0.5, 0.1), 1)
                                      brightness:MIN(MAX(level * 1.5, 0.3), 1)
                                           alpha:1.f];
    gradient.colors = @[ (id)[topColor CGColor],
                         (id)[bottomColor CGColor],
                         (id)[topColor CGColor] ];
    gradient.locations = @[ @0, @1, @1 ];
}

+ (void)configureLayer:(CAGradientLayer*)gradient forHourOfDay:(NSInteger)hour {
    CGFloat intensity = 0;
    if (hour < 12) {
        intensity = hour / 11.f;
    } else {
        intensity = (23 - hour) / 12.f;
    }
    [self configureLayer:gradient withIntensityLevel:intensity];
}

+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth
{
    switch (sleepDepth) {
    case 0:
        return [HelloStyleKit awakeSleepColor];
    case 1:
        return [HelloStyleKit lightSleepColor];
    case 2:
        return [HelloStyleKit intermediateSleepColor];
    default:
        return [HelloStyleKit deepSleepColor];
    }
}

@end
