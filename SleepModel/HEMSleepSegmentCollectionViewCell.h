
#import <UIKit/UIKit.h>
#import "HEMLinedCollectionViewCell.h"

@interface HEMSleepSegmentCollectionViewCell : HEMLinedCollectionViewCell

/**
 *  Set the the amount of the bar that is filled with color, based on
 *  a value between 0 and 1
 *
 *  @param ratio the fill ratio
 *  @param color the color to fill
 */
- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color;
@end
