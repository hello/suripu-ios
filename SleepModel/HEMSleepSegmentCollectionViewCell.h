
#import <UIKit/UIKit.h>

extern CGFloat const HEMLinedCollectionViewCellLineOffset;
extern CGFloat const HEMLinedCollectionViewCellLineWidth;
extern CGFloat const HEMSleepSegmentMinimumFillWidth;
extern CGFloat const HEMSleepLineWidth;

@interface HEMSleepSegmentCollectionViewCell : UICollectionViewCell

/**
 *  Set the the amount of the bar that is filled with color, based on
 *  a value between 0 and 1
 *
 *  @param ratio the fill ratio
 *  @param color the color to fill
 */
- (void)setSegmentRatio:(CGFloat)ratio withColor:(UIColor*)color;

- (void)addTimeLabelWithText:(NSString*)text atHeightRatio:(CGFloat)heightRatio;

- (void)removeAllTimeLabels;

- (UIImage*)dottedLineBorderImageWithColor:(UIColor*)color;

@property (nonatomic, getter=isFirstSegment) BOOL firstSegment;
@property (nonatomic, getter=isLastSegment) BOOL lastSegment;
@property (nonatomic, readonly) CGFloat fillRatio;
@property (nonatomic, strong, readonly) UIColor* fillColor;
@end
