
#import <FDWaveformView/FDWaveformView.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepEventCollectionViewCell.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMTimelineLayoutAttributes.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"
#import "HEMEventBubbleView.h"

@interface HEMSleepEventCollectionViewCell () <AVAudioPlayerDelegate, FDWaveformViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playSoundButton;
@property (weak, nonatomic) IBOutlet FDWaveformView *waveformView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentContainerViewTop;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *playerUpdateTimer;
@property (nonatomic, strong) NSOperationQueue *loadingQueue;
@end

@implementation HEMSleepEventCollectionViewCell

static NSTimeInterval const HEMEventPlayerUpdateInterval = 0.15f;
static NSString *const HEMEventPlayerFileName = @"cache_audio%ld.mp3";

+ (NSAttributedString *)attributedMessageFromText:(NSString *)text {
    return [markdown_to_attr_string(text, 0, [HEMMarkdown attributesForEventMessageText]) trim];
}

- (void)applyLayoutAttributes:(HEMTimelineLayoutAttributes *)layoutAttributes {
    [self animateContentViewWithAttributes:layoutAttributes];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.loadingQueue = [NSOperationQueue new];
    self.loadingQueue.maxConcurrentOperationCount = 1;
    [self configureAudioPlayer];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentContainerView setMessageText:nil timeText:nil];
}

- (void)configureAudioPlayer {
    self.playSoundButton.enabled = NO;
    self.waveformView.progressColor = [HelloStyleKit tintColor];
    self.waveformView.wavesColor = [HelloStyleKit lightSleepColor];
    self.waveformView.delegate = self;
}

- (void)animateContentViewWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const maxContainerViewTop = 0.f;
    CGFloat const minContainerViewTop = -10;
    CGFloat const motionDelta = 1.f;
    CGFloat ratio = 1 - fabs(attributes.ratioFromCenter);
    CGFloat top = MIN(maxContainerViewTop, fabs(minContainerViewTop) * attributes.ratioFromCenter * -1);
    CGFloat alphaRatio = attributes.ratioFromCenter < 0 ? MIN(1, ratio * 4) : 1;
    if (fabs(self.contentContainerViewTop.constant - top) > motionDelta) {
        self.contentContainerViewTop.constant = top;
        [self setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.05f
                              delay:0
                            options:0
                         animations:^{
                           [self.contentContainerView layoutIfNeeded];
                         }
                         completion:NULL];
    }

    [UIView animateWithDuration:0.05f
                     animations:^{
                       self.contentContainerView.alpha = alphaRatio;
                     }];
}

- (void)setNeedsLayout {
    [self setNeedsDisplay];
    [super setNeedsLayout];
}

- (void)setLoading:(BOOL)isLoading {
    self.playSoundButton.enabled = !isLoading;
}

#pragma mark - Audio

- (void)showAudioPlayer:(BOOL)isVisible {
    self.playSoundButton.enabled = NO;
}

- (void)setAudioURL:(NSURL *)audioURL {
    [self stopAudio];
    [self.loadingQueue cancelAllOperations];
    if ([audioURL isEqual:self.waveformView.audioURL]) {
        self.playSoundButton.enabled = YES;
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.loadingQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
                         __strong typeof(weakSelf) strongSelf = weakSelf;
                         NSData *urlData = [NSData dataWithContentsOfURL:audioURL];
                         if (!urlData) {
                             [strongSelf cancelLoading];
                             return;
                         }
                         NSFileManager *fileManager = [NSFileManager defaultManager];
                         NSURL *cache =
                             [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
                         NSString *fileName = [NSString stringWithFormat:HEMEventPlayerFileName, (long)[audioURL hash]];
                         NSURL *localFile = [cache URLByAppendingPathComponent:fileName];
                         BOOL success = [urlData writeToURL:localFile atomically:YES];
                         if (!success) {
                             [strongSelf cancelLoading];
                             return;
                         }
                         [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
                                                         strongSelf.waveformView.audioURL = localFile;
                                                         strongSelf.waveformView.completion
                                                             = ^(NSURL *processedURL, BOOL success) {
                                                               if (success)
                                                                   [strongSelf handleLoadingSuccess];
                                                             };
                                                       }]];
                       }]];
}

- (void)cancelLoading {
    __weak typeof(self) weakSelf = self;
    [[NSOperationQueue mainQueue] addOperation:[NSBlockOperation blockOperationWithBlock:^{
                                    [weakSelf handleLoadingFailure];
                                  }]];
}

- (IBAction)toggleAudio {
    if ([self.player isPlaying])
        [self stopAudio];
    else
        [self playAudio];
}

- (void)playAudio {
    NSURL *url = self.waveformView.audioURL;
    if (!url)
        return;
    if ([self.player isPlaying])
        [self.player stop];
    [self.playerUpdateTimer invalidate];
    NSError *error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.player.delegate = self;
    if (error) {
        [self stopAudio];
    } else {
        [self.waveformView setProgressRatio:0];
        [self.player play];
        [self.playSoundButton setImage:[UIImage imageNamed:@"stopSound"] forState:UIControlStateNormal];
        self.playerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:HEMEventPlayerUpdateInterval
                                                                  target:self
                                                                selector:@selector(updateAudioProgress)
                                                                userInfo:nil
                                                                 repeats:YES];
    }
}

- (void)stopAudio {
    [self.playerUpdateTimer invalidate];
    [self.waveformView setProgressRatio:1];
    [self.playSoundButton setImage:[UIImage imageNamed:@"playSound"] forState:UIControlStateNormal];
    [self.player stop];
    self.player = nil;
}

- (void)updateAudioProgress {
    [self.waveformView setProgressRatio:self.player.currentTime / self.player.duration];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    [self stopAudio];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self stopAudio];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    [self stopAudio];
}

#pragma mark FDWaveformView

- (void)waveformViewWillLoad:(FDWaveformView *)waveformView {
    [self performSelectorOnMainThread:@selector(handleLoadingStart) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView {
    [self performSelectorOnMainThread:@selector(handleLoadingSuccess) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidFail:(FDWaveformView *)waveformView error:(NSError *)error {
    [self performSelectorOnMainThread:@selector(handleLoadingFailure) withObject:nil waitUntilDone:NO];
}

- (void)handleLoadingStart {
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingFailure {
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingSuccess {
    self.playSoundButton.enabled = YES;
}

@end
