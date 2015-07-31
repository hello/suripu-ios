
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@class HEMWaveform, HEMEventBubbleView;

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet HEMEventBubbleView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text;

- (void)layoutWithImage:(UIImage *)image
                message:(NSString *)text
                   time:(NSAttributedString *)timeText
               waveform:(HEMWaveform *)waveform;

- (void)updateAudioDisplayProgressWithRatio:(CGFloat)ratio;
@end
