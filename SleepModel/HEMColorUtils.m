
#import "HEMColorUtils.h"
#import "HelloStyleKit.h"

@implementation HEMColorUtils

+ (void)configureLayer:(CAGradientLayer*)gradient
    withIntensityLevel:(CGFloat)level
{
    UIColor* topColor = [UIColor colorWithHue:0.67
                                   saturation:MIN(MAX(level * 0.8, 0.15), 0.8)
                                   brightness:MIN(MAX(level * 0.5, 0.25), 1)
                                        alpha:1.f];
    UIColor* middleColor = [UIColor colorWithHue:0.62
                                      saturation:MIN(MAX(level * 0.6, 0.1), 1)
                                      brightness:MIN(MAX(level * 0.8, 0.3), 1)
                                           alpha:1.f];
    UIColor* bottomColor = [UIColor colorWithHue:0.54
                                      saturation:MIN(MAX(level * 0.3, 0.1), 1)
                                      brightness:MIN(MAX(level * 1.1, 0.3), 1)
                                           alpha:1.f];
    gradient.colors = @[ (id)[topColor CGColor],
                         (id)[middleColor CGColor],
                         (id)[bottomColor CGColor] ];
    gradient.locations = @[ @0, @(0.4), @1 ];
}

+ (void)configureLayer:(CAGradientLayer*)gradient forHourOfDay:(NSInteger)hour {
    CGFloat intensity = 0;
    if (hour < 16) {
        intensity = hour / 12.f;
    } else {
        intensity = (23 - hour) / 8.f;
    }
    [self configureLayer:gradient withIntensityLevel:intensity];
}

+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth
{
    if (sleepDepth == 0)
        return [HelloStyleKit lightSleepColor];
    else if (sleepDepth == 100)
        return [HelloStyleKit deepSleepColor];
    else if (sleepDepth < 60)
        return [HelloStyleKit lightSleepColor];
    else
        return [HelloStyleKit intermediateSleepColor];
}

@end
