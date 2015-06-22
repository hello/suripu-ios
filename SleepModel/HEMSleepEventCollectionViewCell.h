
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@class FDWaveformView, HEMEventBubbleView;

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, weak) IBOutlet HEMEventBubbleView *contentContainerView;

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text;

- (void)showAudioPlayer:(BOOL)isVisible;
- (void)setAudioURL:(NSURL *)audioURL;
- (IBAction)toggleAudio;
- (void)stopAudio;
- (void)playAudio;

@end
