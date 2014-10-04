
#import <UIKit/UIKit.h>

extern CGFloat HEMLinedCollectionViewCellLineOffset;
extern CGFloat HEMLinedCollectionViewCellLineWidth;

@interface HEMSleepSegmentCollectionViewCell : UICollectionViewCell

/**
 *  Set the the amount of the bar that is filled with color, based on
 *  a value between 0 and 1
 *
 *  @param ratio the fill ratio
 *  @param color the color to fill
 */
- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color;

@property (nonatomic, getter=isFirstSegment) BOOL firstSegment;
@property (nonatomic, getter=isLastSegment) BOOL lastSegment;
@property (nonatomic, readonly) CGFloat fillRatio;
@property (nonatomic, strong, readonly) UIColor* fillColor;
@end
