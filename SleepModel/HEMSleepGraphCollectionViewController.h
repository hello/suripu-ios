
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 1,
    HEMSleepGraphCollectionViewHistorySection = 2,
};

@interface HEMSleepGraphCollectionViewController : UICollectionViewController

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
