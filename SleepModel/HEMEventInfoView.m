//
//  HEMEventInfoView.m
//  Sense
//
//  Created by Delisa Mason on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENSettings.h>
#import <FDWaveformView/FDWaveformView.h>
#import <SpinKit/RTSpinKitView.h>
#import <markdown_peg.h>
#import "HEMEventInfoView.h"
#import "HEMMarkdown.h"
#import "HEMPaddedRoundedLabel.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMEventInfoView () <AVAudioPlayerDelegate, FDWaveformViewDelegate>
@property (nonatomic, strong) AVAudioPlayer* player;
@property (nonatomic, strong) NSTimer* playerUpdateTimer;
@property (strong, nonatomic, readwrite) NSDictionary* markdownAttributes;
@property (strong, nonatomic, readwrite) NSDateFormatter* timestampDateFormatter;
@end

@implementation HEMEventInfoView

static CGFloat const HEMEventInfoViewCaretRadius = 8.f;
static CGFloat const HEMEventInfoViewCaretInset = 5.f;
static CGFloat const HEMEventInfoViewCaretDepth = 6.f;
static CGFloat const HEMEventInfoViewCaretYOffset = 10.f;
static CGFloat const HEMEventInfoViewCornerRadius = 4.f;
static NSTimeInterval const HEMEventInfoViewPlayerUpdateInterval = 0.15f;

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self configureAudioPlayer];
    [self configureTextSettings];
    self.caretPosition = HEMEventInfoViewCaretPositionTop;
    self.verifyDataButton.hidden = YES;
}

- (void)configureAudioPlayer
{
    self.waveformView.progressColor = [UIColor colorWithHue:0.56 saturation:1 brightness:1 alpha:1];
    self.waveformView.wavesColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    self.waveformView.delegate = self;
    self.spinnerView.color = self.waveformView.progressColor;
    self.spinnerView.spinnerSize = CGRectGetHeight(self.playSoundButton.bounds);
    self.spinnerView.style = RTSpinKitViewStyleArc;
    self.spinnerView.hidesWhenStopped = YES;
    self.spinnerView.backgroundColor = [UIColor clearColor];
    [self.spinnerView stopAnimating];
    self.playSoundButton.hidden = YES;
}

- (void)configureTextSettings
{
    self.markdownAttributes = [HEMMarkdown attributesForEventInfoViewText];
    self.timestampDateFormatter = [NSDateFormatter new];
    self.timestampDateFormatter.dateFormat = ([SENSettings timeFormat] == SENTimeFormat12Hour) ? @"h:mm a" : @"H:mm";
}

- (void)dealloc
{
    [_player stop];
    [_playerUpdateTimer invalidate];
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
        self.playerUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:HEMEventInfoViewPlayerUpdateInterval
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

#pragma mark - Drawing

- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawRoundedContainerInRect:rect];
}

- (void)drawRoundedContainerInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect containerRect = CGRectMake(CGRectGetMinX(rect) + HEMEventInfoViewCaretDepth + HEMEventInfoViewCaretInset, CGRectGetMinY(rect), CGRectGetWidth(rect) - HEMEventInfoViewCaretDepth - HEMEventInfoViewCaretInset, CGRectGetHeight(rect));
    UIBezierPath* bezierPath = [UIBezierPath bezierPathWithRoundedRect:containerRect cornerRadius:HEMEventInfoViewCornerRadius + 1];
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0 alpha:0.05f].CGColor);
    [bezierPath fill];

    CGFloat caretYOffset = [self yOffsetForCaretPointInRect:rect];
    CGRect caretRect = CGRectMake(CGRectGetMinX(rect) + HEMEventInfoViewCaretInset,
                                  caretYOffset - HEMEventInfoViewCaretRadius,
                                  HEMEventInfoViewCaretRadius,
                                  HEMEventInfoViewCaretRadius * 2.2);
    [self drawCaretInRect:caretRect];


    bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(containerRect, 1, 1) cornerRadius:HEMEventInfoViewCornerRadius];
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.f alpha:1.f].CGColor);
    [bezierPath fill];
    caretRect.origin.x += 1;
    [self drawCaretInRect:caretRect];
}

- (void)drawCaretInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);

    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));

    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (CGFloat)yOffsetForCaretPointInRect:(CGRect)rect
{
    switch (self.caretPosition) {
    case HEMEventInfoViewCaretPositionMiddle:
        return CGRectGetMidY(rect);
    case HEMEventInfoViewCaretPositionBottom:
        return CGRectGetMaxY(rect) - HEMEventInfoViewCaretYOffset - HEMEventInfoViewCaretRadius;
    case HEMEventInfoViewCaretPositionTop:
    default:
        return HEMEventInfoViewCaretYOffset + HEMEventInfoViewCaretRadius;
    }
}

@end
