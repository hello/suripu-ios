
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
    [self layoutContainerViewWithAttributes:layoutAttributes];
    [self animateContentsWithAttributes:layoutAttributes];
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

- (void)animateContentsWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const minContainerViewScale = 0.9;
    CGFloat scaleDiff = 1 - minContainerViewScale;
    CGFloat ratio = 1 - fabs(attributes.ratioFromCenter);
    CGFloat scale = attributes.ratioFromCenter < 0 ? MIN(1, (scaleDiff * ratio * 4) + minContainerViewScale) : 1;
    CGFloat alphaRatio = attributes.ratioFromCenter < 0 ? MIN(1, ratio * 4) : 1;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGFloat width = CGRectGetWidth(self.contentContainerView.bounds);
    CGFloat inset = floorf(-(width - (width * scale)) / 2);
    BOOL isIdentity = scale == 1 && fabs(inset) < 1;
    CGAffineTransform combinedTransform = isIdentity ? CGAffineTransformIdentity
                                                     : CGAffineTransformTranslate(scaleTransform, inset, inset);

    self.contentContainerView.alpha = alphaRatio;
    if (!CGAffineTransformEqualToTransform(self.contentContainerView.transform, combinedTransform)) {
        self.contentContainerView.transform = combinedTransform;
    }
}

- (void)layoutContainerViewWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const containerViewLeft = 10.f;
    CGFloat const maxContainerViewTop = 10.f;
    CGFloat const minContainerViewTop = 0.f;
    CGFloat base;
    if (attributes != nil) {
        base = maxContainerViewTop * attributes.ratioFromCenter * -1;
    } else {
        base = CGRectGetMinY(self.contentContainerView.frame);
    }
    CGFloat top = floorf(MAX(MIN(maxContainerViewTop, base), minContainerViewTop));
    CGSize size = [self.contentContainerView intrinsicContentSize];
    CGRect frame = CGRectMake(containerViewLeft, top, size.width, size.height);
    self.contentContainerView.frame = frame;
}

- (void)layoutIconImageView {
    CGFloat const iconImageLeft = 4.f;
    CGFloat const iconImageTop = 4.f;
    CGFloat const iconImageDiameter = 40.f;
    CGRect frame = CGRectMake(iconImageLeft, iconImageTop, iconImageDiameter, iconImageDiameter);
    self.eventTypeImageView.frame = frame;
}

- (void)layoutTimeLabel {
    CGFloat const timeLabelRight = 8.f;
    CGFloat containerWidth = CGRectGetWidth(self.contentContainerView.bounds);
    [self.eventTimeLabel sizeToFit];
    CGFloat left = containerWidth - CGRectGetWidth(self.eventTimeLabel.bounds) - timeLabelRight;
    CGFloat top = CGRectGetMidY(self.eventTypeImageView.frame);
    CGRect frame = self.eventTimeLabel.frame;
    frame.origin = CGPointMake(left, top);
    self.eventTimeLabel.frame = frame;
}

- (void)layoutMessageLabel {
    CGFloat const messageLabelLeft = 52.f;
    CGFloat const messageLabelTop = 13.f;
    CGFloat const messageLabelRight = 8.f;
    CGFloat containerWidth = CGRectGetWidth(self.contentContainerView.bounds);
    CGFloat width = containerWidth - messageLabelLeft - CGRectGetWidth(self.eventTimeLabel.bounds) - messageLabelRight;
    CGRect frame = CGRectMake(messageLabelLeft, messageLabelTop, width,
                              [self.eventMessageLabel.attributedText sizeWithWidth:width].height);
    self.eventMessageLabel.frame = frame;
}

- (void)setNeedsLayout {
    [self setNeedsDisplay];
    [super setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutContainerViewWithAttributes:nil];
    [self layoutIconImageView];
    [self layoutTimeLabel];
    [self layoutMessageLabel];
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
