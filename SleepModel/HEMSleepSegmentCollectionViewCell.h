
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
 *  @param ratio     the fill ratio
 *  @param color     the color to fill
 *  @param lineColor the color to draw down the center
 */
- (void)setSegmentRatio:(CGFloat)ratio withFillColor:(UIColor*)color lineColor:(UIColor*)lineColor;

- (void)addTimeLabelWithText:(NSString*)text atHeightRatio:(CGFloat)heightRatio;

- (NSUInteger)numberOfTimeLabels;

- (void)removeAllTimeLabels;

- (UIImage*)dottedLineBorderImageWithColor:(UIColor*)color;

@property (nonatomic, getter=isFirstSegment) BOOL firstSegment;
@property (nonatomic, getter=isLastSegment) BOOL lastSegment;
@property (nonatomic, readonly) CGFloat fillRatio;
@property (nonatomic, strong, readonly) UIColor* fillColor;
@property (nonatomic, strong, readonly) UIColor* lineColor;
@end
