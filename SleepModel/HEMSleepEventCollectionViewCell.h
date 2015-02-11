
#import <UIKit/UIKit.h>
#import "HEMSleepSegmentCollectionViewCell.h"

@class FDWaveformView, RTSpinKitView, HEMSleepEventButton;

@interface HEMSleepEventCollectionViewCell : HEMSleepSegmentCollectionViewCell

@property (weak, nonatomic) IBOutlet HEMSleepEventButton* eventTypeButton;
@property (weak, nonatomic) IBOutlet UILabel* eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel* eventTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton* playSoundButton;
@property (weak, nonatomic) IBOutlet FDWaveformView* waveformView;
@property (weak, nonatomic) IBOutlet RTSpinKitView* spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *verifyDataButton;

+ (NSAttributedString*)attributedMessageFromText:(NSString*)text;

- (void)useExpandedLayout:(BOOL)isExpanded targetSize:(CGSize)size animated:(BOOL)animated;
- (void)showAudioPlayer:(BOOL)isVisible;
- (void)setAudioURL:(NSURL*)audioURL;
- (IBAction)toggleAudio;
- (void)stopAudio;
- (void)playAudio;

@end
