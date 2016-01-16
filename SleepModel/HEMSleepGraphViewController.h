
#import <UIKit/UIKit.h>
#import "HEMBaseController.h"

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 1,
};

extern CGFloat const HEMTimelineHeaderCellHeight;

@interface HEMSleepGraphViewController : HEMBaseController

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate *dateForNightOfSleep;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign, getter=isLastNight, readonly) BOOL lastNight;
@end
