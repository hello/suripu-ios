
#import "HEMSleepEventCollectionViewCell.h"
#import <FDWaveformView/FDWaveformView.h>
#import <SpinKit/RTSpinKitView.h>
#import "HelloStyleKit.h"
#import "HEMMarkdown.h"

@interface HEMSleepEventCollectionViewCell ()<AVAudioPlayerDelegate, FDWaveformViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sleepEventButtonHeightConstraint;
@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* playerUpdateTimer;
@end

@implementation HEMSleepEventCollectionViewCell

static CGFloat const HEMEventButtonSize = 40.f;
static NSTimeInterval const HEMEventPlayerUpdateInterval = 0.15f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor whiteColor];
    self.verifyDataButton.hidden = YES;
    [self configureAudioPlayer];
}

- (void)prepareForReuse
{
    self.waveformView.hidden = YES;
    self.verifyDataButton.hidden = YES;
    self.playSoundButton.hidden = YES;
}

- (void)configureAudioPlayer
{
    self.waveformView.progressColor = [UIColor colorWithHue:0.56 saturation:1 brightness:1 alpha:1];
    self.waveformView.wavesColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    self.waveformView.delegate = self;
    self.waveformView.hidden = YES;
    self.spinnerView.color = self.waveformView.progressColor;
    self.spinnerView.spinnerSize = CGRectGetHeight(self.playSoundButton.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
    [self.spinnerView stopAnimating];
    self.playSoundButton.hidden = YES;
}

- (void)setNeedsLayout
{
    [self setNeedsDisplay];
    [super setNeedsLayout];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = HEMSleepLineWidth;
    CGFloat height = 0;
    CGFloat x = CGRectGetMidX(rect)  - width;
    CGFloat y = CGRectGetMinY(rect);
    CGFloat halfButton = ceilf(HEMEventButtonSize/2);
    CGContextSetFillColorWithColor(ctx, [HelloStyleKit timelineLineColor].CGColor);
    if ([self isLastSegment] && ![self isFirstSegment]) {
        height = halfButton;
    } else if ([self isFirstSegment] && ![self isLastSegment]) {
        height = CGRectGetHeight(rect) - halfButton;
        y = halfButton;
    } else {
        height = CGRectGetHeight(rect);
    }
    CGRect contentRect = CGRectMake(x, CGRectGetMidY(rect), width, height);
    CGContextFillRect(ctx, contentRect);
}


- (void)setLoading:(BOOL)isLoading
{
    if (isLoading)
        [self.spinnerView startAnimating];
    else
        [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = !isLoading;
}

#pragma mark - Audio

- (void)showAudioPlayer:(BOOL)isVisible
{
    self.waveformView.hidden = !isVisible;
    self.playSoundButton.hidden = !isVisible;
    self.playSoundButton.enabled = NO;
    if (isVisible)
        [self.spinnerView startAnimating];
    else
        [self.spinnerView stopAnimating];
}

- (void)setAudioURL:(NSURL *)audioURL
{
    if ([audioURL isEqual:self.waveformView.audioURL]) {
        self.playSoundButton.enabled = YES;
        return;
    }
    self.waveformView.audioURL = audioURL;
    __weak typeof(self) weakSelf = self;
    self.waveformView.completion = ^(NSURL* processedURL, BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (success)
            [strongSelf handleLoadingSuccess];
    };
}

- (IBAction)toggleAudio
{
    if ([self.player isPlaying])
        [self stopAudio];
    else
        [self playAudio];
}

- (void)playAudio
{
    NSURL* url = self.waveformView.audioURL;
    if (!url)
        return;
    if ([self.player isPlaying])
        [self.player stop];
    [self.playerUpdateTimer invalidate];
    NSError* error = nil;
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

- (void)stopAudio
{
    [self.playerUpdateTimer invalidate];
    [self.waveformView setProgressRatio:1];
    [self.playSoundButton setImage:[UIImage imageNamed:@"playSound"] forState:UIControlStateNormal];
    [self.player stop];
    self.player = nil;
}

- (void)updateAudioProgress
{
    [self.waveformView setProgressRatio:self.player.currentTime/self.player.duration];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self stopAudio];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self stopAudio];
}

#pragma mark FDWaveformView

- (void)waveformViewWillLoad:(FDWaveformView *)waveformView
{
    [self performSelectorOnMainThread:@selector(handleLoadingStart) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [self performSelectorOnMainThread:@selector(handleLoadingSuccess) withObject:nil waitUntilDone:NO];
}

- (void)waveformViewDidFail:(FDWaveformView *)waveformView error:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleLoadingFailure) withObject:nil waitUntilDone:NO];
}

- (void)handleLoadingStart
{
    if ([self.spinnerView isAnimating])
        return;
    [self.spinnerView startAnimating];
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingFailure
{
    [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = NO;
}

- (void)handleLoadingSuccess
{
    if ([self.spinnerView isAnimating])
        [self.spinnerView stopAnimating];
    self.playSoundButton.enabled = YES;
}


@end
