
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 1,
    HEMSleepGraphCollectionViewPresleepSection = 2,
};

extern CGFloat const HEMTimelineHeaderCellHeight;

@class HEMSleepGraphView;

@protocol HEMSleepEventActionDelegate <NSObject>

- (void)didTapEventButton:(UIButton*)sender;

@end

@interface HEMSleepGraphViewController : UIViewController <HEMSleepEventActionDelegate>

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
