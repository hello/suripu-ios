
#import <FDWaveformView/FDWaveformView.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "HEMSleepEventCollectionViewCell.h"
#import "HEMSleepEventButton.h"
#import "NSAttributedString+HEMUtils.h"
#import "HEMTimelineLayoutAttributes.h"
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"

@interface HEMSleepEventCollectionViewCell () <AVAudioPlayerDelegate, FDWaveformViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIButton *playSoundButton;
@property (weak, nonatomic) IBOutlet FDWaveformView *waveformView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentContainerViewTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentContainerViewLeading;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentContainerViewTrailing;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSTimer *playerUpdateTimer;
@property (nonatomic, strong) UIView *gradientContainerTopView;
@property (nonatomic, strong) UIView *gradientContainerBottomView;
@property (nonatomic, strong) CAGradientLayer *gradientTopLayer;
@property (nonatomic, strong) CAGradientLayer *gradientBottomLayer;
@property (nonatomic, strong) NSOperationQueue *loadingQueue;
@end

@implementation HEMSleepEventCollectionViewCell

static CGFloat const HEMEventButtonSize = 40.f;
static CGFloat const HEMEventBlurHeight = 60.f;
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
    [self configureGradientViews];
}

- (void)configureAudioPlayer {
    self.playSoundButton.enabled = NO;
    self.waveformView.progressColor = [HelloStyleKit tintColor];
    self.waveformView.wavesColor = [HelloStyleKit lightSleepColor];
    self.waveformView.delegate = self;
}

- (void)configureGradientViews {
    self.gradientContainerTopView = [UIView new];
    self.gradientContainerTopView.alpha = 0;
    self.gradientContainerBottomView = [UIView new];
    self.gradientContainerBottomView.alpha = 0;
    [self insertSubview:self.gradientContainerTopView atIndex:0];
    [self insertSubview:self.gradientContainerBottomView atIndex:0];
    NSArray *topColors = @[
        (id)[[HelloStyleKit tintColor] colorWithAlphaComponent:0]
            .CGColor,
        (id)[[HelloStyleKit tintColor] colorWithAlphaComponent:0.1f].CGColor
    ];

    CAGradientLayer *topLayer = [CAGradientLayer layer];
    topLayer.colors = topColors;
    topLayer.frame = self.gradientContainerTopView.bounds;
    topLayer.locations = @[ @0, @1 ];
    topLayer.startPoint = CGPointZero;
    topLayer.endPoint = CGPointMake(0, 1);
    self.gradientTopLayer = topLayer;
    [self.gradientContainerTopView.layer insertSublayer:topLayer atIndex:0];
    CAGradientLayer *bottomLayer = [CAGradientLayer layer];
    bottomLayer.colors = [[topColors reverseObjectEnumerator] allObjects];
    bottomLayer.frame = self.gradientContainerTopView.bounds;
    bottomLayer.locations = @[ @0, @1 ];
    bottomLayer.startPoint = CGPointZero;
    bottomLayer.endPoint = CGPointMake(0, 1);
    self.gradientBottomLayer = bottomLayer;
    [self.gradientContainerBottomView.layer insertSublayer:bottomLayer atIndex:0];
}

- (void)animateContentViewWithAttributes:(HEMTimelineLayoutAttributes *)attributes {
    CGFloat const minContainerViewLeading = -10.f;
    CGFloat const maxContainerViewLeading = 8.f;
    CGFloat const minContainerViewTrailing = -60.f;
    CGFloat const maxContainerViewTrailing = -42.f;
    CGFloat const maxContainerViewTop = 10.f;
    CGFloat const minContainerViewTop = 0;
    CGFloat const motionDelta = 1.f;
    CGFloat ratio = 1 - fabs(attributes.ratioFromCenter);
    CGFloat adjustedRatio = MIN(1, ratio * 5);
    CGFloat diff = (maxContainerViewLeading - minContainerViewLeading) * adjustedRatio;
    CGFloat leading = MIN(minContainerViewLeading + diff, maxContainerViewLeading);
    CGFloat trailing = MIN(minContainerViewTrailing + diff, maxContainerViewTrailing);
    CGFloat top = MAX(minContainerViewTop, maxContainerViewTop * attributes.ratioFromCenter);
    CGFloat alphaRatio = ratio < 0 ? MAX(0.8, MIN(1, fabs(ratio))) : 1;
    if (fabs(self.contentContainerViewTop.constant - top) > motionDelta
        || fabs(self.contentContainerViewTrailing.constant - trailing) > motionDelta
        || fabs(self.contentContainerViewLeading.constant - leading) > motionDelta) {
        self.contentContainerViewLeading.constant = leading;
        self.contentContainerViewTrailing.constant = trailing;
        self.contentContainerViewTop.constant = top;
        [self setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.05f
                              delay:0
                            options:0
                         animations:^{ [self.contentContainerView layoutIfNeeded]; }
                         completion:NULL];
    }

    [UIView animateWithDuration:0.05f animations:^{ self.contentContainerView.alpha = alphaRatio; }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat inset = HEMEventButtonSize / 2;
    CGFloat width = CGRectGetWidth(self.bounds);
    self.gradientContainerTopView.frame = CGRectMake(0, -HEMEventBlurHeight + inset, width, HEMEventBlurHeight);
    self.gradientContainerBottomView.frame
        = CGRectMake(0, CGRectGetHeight(self.bounds) - inset, width, HEMEventBlurHeight);
    self.gradientTopLayer.frame = self.gradientContainerTopView.bounds;
    [self.gradientTopLayer setNeedsLayout];
    self.gradientBottomLayer.frame = self.gradientContainerBottomView.bounds;
    [self.gradientBottomLayer setNeedsLayout];
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
    [[NSOperationQueue mainQueue]
        addOperation:[NSBlockOperation blockOperationWithBlock:^{ [weakSelf handleLoadingFailure]; }]];
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
