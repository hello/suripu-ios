
#import <Foundation/Foundation.h>

@interface HEMColorUtils : NSObject

/**
 *  Configures a dynamically-colored gradient layer with a brightness
 *  and saturation value scaled using intensity level.
 *
 *  @param level scaled brightness and saturation
 */
+ (void)configureLayer:(CAGradientLayer*)gradient
    withIntensityLevel:(CGFloat)level;

/**
 *  Returns the corresponding color style for the depth of sleep between
 *  0 (awake) and 3 (deep sleep)
 *
 *  @param sleepDepth depth of sleep
 *
 *  @return color
 */
+ (UIColor*)colorForSleepDepth:(NSUInteger)sleepDepth;
@end
