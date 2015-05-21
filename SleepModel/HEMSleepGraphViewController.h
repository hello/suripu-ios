
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMSleepGraphCollectionViewSection) {
    HEMSleepGraphCollectionViewSummarySection = 0,
    HEMSleepGraphCollectionViewSegmentSection = 1,
};

extern CGFloat const HEMTimelineHeaderCellHeight;

@class HEMSleepGraphView;

@protocol HEMSleepEventActionDelegate <NSObject>

- (void)didTapActionSheetButton:(UIButton *)sender;

@end

@interface HEMSleepGraphViewController : UIViewController <HEMSleepEventActionDelegate>

/**
 *  The date which is represented by this controller
 */
@property (nonatomic, strong) NSDate *dateForNightOfSleep;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign, getter=isLastNight, readonly) BOOL lastNight;
@end
