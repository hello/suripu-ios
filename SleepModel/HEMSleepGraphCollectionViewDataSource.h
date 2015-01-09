
#import <Foundation/Foundation.h>

@class SENSleepResultSegment;
@class HEMSleepSummaryCollectionViewCell;

extern NSString* const HEMSleepEventTypeWakeUp;

@protocol HEMSleepGraphActionDelegate <NSObject>

@optional

- (void)drawerButtonTapped:(UIButton*)button;
- (void)shareButtonTapped:(UIButton*)button;
- (void)zoomButtonTapped:(UIButton*)sender;
- (BOOL)shouldHideShareButton;
- (BOOL)shouldEnableZoomButton;

@end

@interface HEMSleepGraphCollectionViewDataSource : NSObject <UICollectionViewDataSource>

+ (NSString*)localizedNameForSleepEventType:(NSString*)eventType;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView sleepDate:(NSDate*)date;

/**
 *  Updates and reloads data
 */
- (void)reloadData;

/**
 *  Fetch the sleep data corresponding to a given index path
 *
 *  @param indexPath the index path to key
 *
 *  @return sleep data or nil
 */
- (SENSleepResultSegment*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath;

/**
 *  Detect whether a segment represents sleep time elapsed or an event
 *
 *  @param indexPath index path of the segment to check
 *
 *  @return YES if there is no event present on the computed segment
 */
- (BOOL)segmentForSleepExistsAtIndexPath:(NSIndexPath*)indexPath;

/**
 *  Detect whether a segment represents a sleep event
 *
 *  @param indexPath index path of the segment to check
 *
 *  @return YES if there is an event present on the computed segment
 */
- (BOOL)segmentForEventExistsAtIndexPath:(NSIndexPath*)indexPath;

- (NSUInteger)numberOfSleepSegments;

- (HEMSleepSummaryCollectionViewCell*)sleepSummaryCell;

@property (nonatomic, strong, readonly) SENSleepResult* sleepResult;
@end
