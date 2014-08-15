
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
@end
