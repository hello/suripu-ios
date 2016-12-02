
#import <Foundation/Foundation.h>

@class SENTimelineSegment;
@class HEMSleepSummaryCollectionViewCell;
@class HEMTimelineService;

@protocol HEMSleepGraphActionDelegate <NSObject>

@required

- (BOOL)shouldHideSegmentCellContents;

- (void)toggleAudio:(UIButton*)button;
@end

@interface HEMSleepGraphCollectionViewDataSource : NSObject <UICollectionViewDataSource>

+ (NSString *)localizedNameForSleepEventType:(NSString *)eventType;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                             sleepDate:(NSDate *)date
                       timelineService:(HEMTimelineService*)timelineService;

/**
 * Refetches the data from disk
 */
- (void)refreshData;

/**
 *  Updates and reloads data
 */
- (void)reloadData:(void (^)(NSError*))completion;

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

/**
 *  Detect if an event segment has an associated audio snippet
 *
 *  @param indexPath index path of the segment to check
 *
 *  @return YES if there is a sound present on the computed segment
 */
- (BOOL)segmentForSoundExistsAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Load the sound for a given index path into NSData
 *
 *  @param indexPath index path of the sound event
 *
 *  @return sound data or nil if none or error
 */
- (NSData *)audioDataForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Text summarizing a sleep segment
 *
 *  @param indexPath index path of the segment
 *
 *  @return summary text
 */
- (NSAttributedString *)summaryForSegmentAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)accessibleSummaryForSegmentAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)numberOfSleepSegments;

- (BOOL)dateIsLastNight;

- (BOOL)hasTimelineData;

- (BOOL)hasSleepScore;

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

@property (nonatomic, strong, readonly) SENTimeline *sleepResult;
@property (nonatomic, getter=isLoading, readonly) BOOL loading;
@end
