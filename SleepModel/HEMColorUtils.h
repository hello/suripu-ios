
#import <Foundation/Foundation.h>

@interface HEMColorUtils : NSObject

+ (CAGradientLayer*)layerWithBlueBackgroundGradientInFrame:(CGRect)frame;

/**
 *  Configures a dynamically-colored gradient layer with a brightness
 *  and saturation value scaled using intensity level.
 *
 *  @param frame frame of the layer
 *  @param level scaled brightness and saturation
 */
+ (void)configureLayer:(CAGradientLayer*)gradient
    withBlueBackgroundGradientInFrame:(CGRect)frame
                       intensityLevel:(CGFloat)level;
@end
