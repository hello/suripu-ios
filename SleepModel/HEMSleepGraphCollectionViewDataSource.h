
#import <Foundation/Foundation.h>

@class SENTimelineSegment;
@class HEMSleepSummaryCollectionViewCell;

@protocol HEMSleepGraphActionDelegate <NSObject>

@required

- (void)didTapSummaryButton:(UIButton *)button;
- (void)didTapDrawerButton:(UIButton *)button;
- (void)didTapShareButton:(UIButton *)button;
- (void)didTapDateButton:(UIButton *)button;
- (BOOL)shouldHideSegmentCellContents;

@end

@interface HEMSleepGraphCollectionViewDataSource : NSObject <UICollectionViewDataSource>

+ (NSString *)localizedNameForSleepEventType:(NSString *)eventType;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView sleepDate:(NSDate *)date;

/**
 * Refetches the data from disk
 */
- (void)refreshData;

/**
 *  Updates and reloads data
 */
- (void)reloadData:(void (^)(void))completion;

/**
 *  Fetch the sleep data corresponding to a given index path
 *
 *  @param indexPath the index path to key
 *
 *  @return sleep data or nil
 */
- (SENTimelineSegment *)sleepSegmentForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Detect whether a segment represents sleep time elapsed or an event
 *
 *  @param indexPath index path of the segment to check
 *
 *  @return YES if there is no event present on the computed segment
 */
- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Detect whether a segment represents a sleep event
 *
 *  @param indexPath index path of the segment to check
 *
 *  @return YES if there is an event present on the computed segment
 */
- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)numberOfSleepSegments;

- (BOOL)dateIsLastNight;

/**
 *  Tiny text for timestamps
 *
 *  @param date the date to format
 *
 *  @return the text
 */
- (NSAttributedString *)formattedTextForInlineTimestamp:(NSDate *)date;

/**
 *  @return the currently displayed text in the top bar for the date of sleep
 */
- (NSString *)dateTitle;

/**
 *  Set the top bar's state
 *
 *  @param isOpen: YES if the timeilne is currently opened. NO otherwise
 */
- (void)updateTimelineState:(BOOL)isOpen;

@property (nonatomic, strong, readonly) SENTimeline *sleepResult;
@end
