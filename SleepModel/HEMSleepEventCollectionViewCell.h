
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@class FDWaveformView, HEMEventBubbleView;

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet HEMEventBubbleView *contentContainerView;

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text;

- (void)layoutWithImage:(UIImage *)image message:(NSString *)text time:(NSAttributedString *)timeText;
@end
