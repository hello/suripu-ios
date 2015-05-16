
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@class FDWaveformView, RTSpinKitView, HEMSleepEventButton;

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyDataButton;
@property (weak, nonatomic) IBOutlet UIView *audioPlayerView;

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text;

- (void)showAudioPlayer:(BOOL)isVisible;
- (void)setAudioURL:(NSURL *)audioURL;
- (IBAction)toggleAudio;
- (void)stopAudio;
- (void)playAudio;

@end
