
#import <Foundation/Foundation.h>

@class HEMSensorDataHeaderView;
@class SENSleepResultSegment;

extern NSString* const HEMSleepEventTypeWakeUp;
extern NSString* const HEMSleepEventTypeLight;
extern NSString* const HEMSleepEventTypeMotion;
extern NSString* const HEMSleepEventTypeNoise;
extern NSString* const HEMSleepEventTypeFallAsleep;

@interface HEMSleepGraphCollectionViewDataSource : NSObject <UICollectionViewDataSource>

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
 *  Update the text of the sensors view to reflect the sleep data at the top of the view
 */
- (void)updateSensorViewText;

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

@property (nonatomic, weak, readonly) HEMSensorDataHeaderView* sensorDataHeaderView;
@end
