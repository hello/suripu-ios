
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
 *  @param previousRatio the top area fill ratio
 *  @param previousColor the top area color
 */
- (void)setSegmentRatio:(CGFloat)ratio
          withFillColor:(UIColor *)color
          previousRatio:(CGFloat)previousRatio
          previousColor:(UIColor *)previousColor;

- (void)addTimeLabelWithText:(NSAttributedString *)text atHeightRatio:(CGFloat)heightRatio;

- (NSUInteger)numberOfTimeLabels;

- (void)removeAllTimeLabels;

- (UIImage *)lineBorderImageWithColor:(UIColor *)color;

- (void)prepareForEntryAnimation;

- (void)cancelEntryAnimation;

/**
 *  Animate the appearance of the segment bar
 *
 *  @param duration   duration of the animation
 *  @param delay      time to wait before beginning the animation
 *  @param completion block invoked at completion
 */
- (void)performEntryAnimationWithDuration:(NSTimeInterval)duration
                                    delay:(NSTimeInterval)delay
                               completion:(void (^)(BOOL))completion;

@property (nonatomic, getter=isFirstSegment) BOOL firstSegment;
@property (nonatomic, getter=isLastSegment) BOOL lastSegment;
@property (nonatomic, readonly) CGFloat fillRatio;
@property (nonatomic, getter=isWaitingForAnimation, readonly) BOOL waitingForAnimation;
@end
