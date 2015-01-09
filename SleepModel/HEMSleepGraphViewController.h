
#import <UIKit/UIKit.h>
#import "HEMPresleepItemCollectionViewCell.h"

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 2,
    HEMSleepGraphCollectionViewPresleepSection = 1,
};

extern CGFloat const HEMTimelineHeaderCellHeight;

@class HEMSleepGraphView;

@protocol HEMSleepEventActionDelegate <NSObject>

- (void)didTapEventButton:(UIButton*)sender;
- (void)didTapDataVerifyButton:(UIButton*)sender;

@end

@interface HEMSleepGraphViewController : UIViewController <HEMSleepEventActionDelegate, HEMPresleepActionDelegate>

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
