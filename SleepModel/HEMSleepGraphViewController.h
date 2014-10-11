
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 1,
};

@protocol HEMSleepEventActionDelegate <NSObject>

- (void)didTapEventButton:(UIButton*)sender;

@end

@interface HEMSleepGraphViewController : UIViewController <HEMSleepEventActionDelegate>

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate* dateForNightOfSleep;
@end
