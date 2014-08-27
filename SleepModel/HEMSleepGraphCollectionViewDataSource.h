
#import <Foundation/Foundation.h>

@class HEMSensorDataHeaderView;

@interface HEMSleepGraphCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView sleepData:(NSDictionary*)sleepData;

/**
 *  Fetch the sleep data corresponding to a given index path
 *
 *  @param indexPath the index path to key
 *
 *  @return sleep data or nil
 */
- (NSDictionary*)sleepSegmentForIndexPath:(NSIndexPath*)indexPath;

/**
 *  Update the text of the sensors view to reflect the sleep data at the top of the view
 */
- (void)updateSensorViewText;

/**
 *  Expand or hide the event cell at a given position
 *
 *  @param indexPath the index path of the cell to update
 */
- (void)toggleExpansionOfEventCellAtIndexPath:(NSIndexPath*)indexPath;

/**
 *  Check if an event cell is currently expanded to show full size
 *
 *  @param indexPath the index path of the cell to check
 *
 *  @return YES if the cell is currently expanded
 */
- (BOOL)eventCellAtIndexPathIsExpanded:(NSIndexPath*)indexPath;

@property (nonatomic, weak, readonly) HEMSensorDataHeaderView* sensorDataHeaderView;
@end
