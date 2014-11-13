//
//  FDWaveformView
//
//  Created by William Entriken on 10/6/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//


// FROM http://stackoverflow.com/questions/5032775/drawing-waveform-with-avassetreader
// AND http://stackoverflow.com/questions/8298610/waveform-on-ios
// DO SEE http://stackoverflow.com/questions/1191868/uiimageview-scaling-interpolation
// see http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone

#import "FDWaveFormView.h"
#import <UIKit/UIKit.h>

@interface FDWaveformView() <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIImageView *highlightedImage;
@property (nonatomic, strong) UIView *clipping;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, assign) unsigned long int totalSamples;
@property (nonatomic, assign) unsigned long int cachedStartSamples;
@property (nonatomic, assign) unsigned long int cachedEndSamples;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property BOOL renderingInProgress;
@property BOOL loadingInProgress;
@end

@implementation FDWaveformView

static NSInteger const FDWSampleSkipCount = 4;
static CGFloat const FDWNoiseFloor = -50.f;

static CGFloat decibel(CGFloat amplitude) {
    CGFloat a = amplitude < 0 ? -amplitude : amplitude;
    return 20.0 * log10(a/32767.0);
}

static long minMaxX(long x, long min, long max) {
    return x <= min ? min : (x >= max ? max : x);
}

- (void)initialize
{
    self.image = [[UIImageView alloc] initWithFrame:self.bounds];
    self.highlightedImage = [[UIImageView alloc] initWithFrame:self.bounds];
    self.clipping = [[UIView alloc] initWithFrame:self.bounds];
    self.image.contentMode = UIViewContentModeScaleToFill;
    self.highlightedImage.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.image];
    [self.clipping addSubview:self.highlightedImage];
    self.clipping.clipsToBounds = YES;
    [self addSubview:self.clipping];
    self.clipsToBounds = YES;
    
    self.wavesColor = [UIColor blackColor];
    self.progressColor = [UIColor blueColor];
    
    self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    self.pinchRecognizer.delegate = self;
    [self addGestureRecognizer:self.pinchRecognizer];

    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panRecognizer.delegate = self;
    [self addGestureRecognizer:self.panRecognizer];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:self.tapRecognizer];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    if (self = [super initWithCoder:aCoder])
        [self initialize];
    return self;
}

- (id)initWithFrame:(CGRect)rect
{
    if (self = [super initWithFrame:rect])
        [self initialize];
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    _audioURL = nil;
    _image = nil;
    _highlightedImage = nil;
    _clipping = nil;
    _asset = nil;
    _wavesColor = nil;
    _progressColor = nil;
}

- (void)setAudioURL:(NSURL *)audioURL
{
    if ([_audioURL isEqual:audioURL])
        return;

    _audioURL = audioURL;
    self.loadingInProgress = YES;
    if ([self.delegate respondsToSelector:@selector(waveformViewWillLoad:)])
        [self.delegate waveformViewWillLoad:self];
    self.asset = [AVURLAsset URLAssetWithURL:audioURL options:nil];

    [self.asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
        self.loadingInProgress = NO;
        if ([self.delegate respondsToSelector:@selector(waveformViewDidLoad:)])
            [self.delegate waveformViewDidLoad:self];
        
        NSError *error = nil;
        AVKeyValueStatus durationStatus = [self.asset statusOfValueForKey:@"duration" error:&error];
        switch (durationStatus) {
            case AVKeyValueStatusLoaded:
                self.image.image = nil;
                self.highlightedImage.image = nil;
                self.totalSamples = (unsigned long int) self.asset.duration.value;
                _progressSamples = 0; // skip custom setter
                _zoomStartSamples = 0; // skip custom setter
                _zoomEndSamples = (unsigned long int) self.asset.duration.value; // skip custom setter
                [self setNeedsDisplay];
                [self performSelectorOnMainThread:@selector(setNeedsLayout) withObject:nil waitUntilDone:NO];
                break;
                
            case AVKeyValueStatusFailed:
            case AVKeyValueStatusCancelled:
            default:
                if ([self.delegate respondsToSelector:@selector(waveformViewDidFail:error:)])
                    [self.delegate waveformViewDidFail:self error:error];
                break;
        }
    }];
}

- (void)setProgressSamples:(unsigned long)progressSamples
{
    if (_progressSamples == progressSamples)
        return;

    _progressSamples = progressSamples;
    if (self.totalSamples) {
        float progress = (float)self.progressSamples / self.totalSamples;
        self.clipping.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds)*progress, CGRectGetHeight(self.bounds));
    }
}

- (void)setProgressRatio:(CGFloat)progressRatio
{
    if (self.totalSamples) {
        CGFloat currentProgressRatio = (float)self.progressSamples / self.totalSamples;
        if (currentProgressRatio == progressRatio)
            return;
        self.progressSamples = self.totalSamples * progressRatio;
    }
}

- (void)setZoomStartSamples:(unsigned long)startSamples
{
    if (_zoomStartSamples == startSamples)
        return;

    _zoomStartSamples = startSamples;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)setZoomEndSamples:(unsigned long)endSamples
{
    if (_zoomEndSamples == endSamples)
        return;

    _zoomEndSamples = endSamples;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.asset || self.renderingInProgress || self.zoomEndSamples == 0)
        return;

    NSURL* audioURL = self.audioURL;
    BOOL needToRender = NO;
    if (!self.image.image)
        needToRender = YES;

    if (self.cachedStartSamples < (unsigned long)minMaxX((float)self.zoomStartSamples, 0, self.totalSamples))
        needToRender = YES;
    if (self.cachedStartSamples > (unsigned long)minMaxX((float)self.zoomStartSamples, 0, self.totalSamples))
        needToRender = YES;
    if (self.cachedEndSamples < (unsigned long)minMaxX((float)self.zoomEndSamples, 0, self.totalSamples))
        needToRender = YES;
    if (self.cachedEndSamples > (unsigned long)minMaxX((float)self.zoomEndSamples, 0, self.totalSamples))
        needToRender = YES;
    if (self.image.image.size.width < self.frame.size.width * [UIScreen mainScreen].scale)
        needToRender = YES;
    if (self.image.image.size.width > self.frame.size.width * [UIScreen mainScreen].scale)
        needToRender = YES;
    if (self.image.image.size.height < self.frame.size.height * [UIScreen mainScreen].scale)
        needToRender = YES;
    if (self.image.image.size.height > self.frame.size.height * [UIScreen mainScreen].scale)
        needToRender = YES;
    if (!needToRender) {
        // We need to place the images which have samples from cachedStart..cachedEnd
        // inside our frame which represents startSamples..endSamples
        // all figures are a portion of our frame size
        float scaledStart = 0, scaledProgress = 0, scaledEnd = 1, scaledWidth = 1;
        if (self.cachedEndSamples > self.cachedStartSamples) {
            scaledStart = ((float)self.cachedStartSamples-self.zoomStartSamples)/(self.zoomEndSamples-self.zoomStartSamples);
            scaledEnd = ((float)self.cachedEndSamples-self.zoomStartSamples)/(self.zoomEndSamples-self.zoomStartSamples);
            scaledWidth = scaledEnd - scaledStart;
            scaledProgress = ((float)self.progressSamples-self.zoomStartSamples)/(self.zoomEndSamples-self.zoomStartSamples);
        }
        CGRect frame = CGRectMake(self.frame.size.width*scaledStart, 0, self.frame.size.width*scaledWidth, self.frame.size.height);
        self.image.frame = self.highlightedImage.frame = frame;
        self.clipping.frame = CGRectMake(0,0,self.frame.size.width*scaledProgress,self.frame.size.height);
        self.clipping.hidden = self.progressSamples <= self.zoomStartSamples;
        return;
    }

    self.renderingInProgress = YES;
    if ([self.delegate respondsToSelector:@selector(waveformViewWillRender:)])
        [self.delegate waveformViewWillRender:self];
    unsigned long int renderStartSamples = minMaxX((long)self.zoomStartSamples, 0, self.totalSamples);
    unsigned long int renderEndSamples = minMaxX((long)self.zoomEndSamples, 0, self.totalSamples);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self renderPNGAudioPictogramLogForAsset:self.asset
                                    startSamples:renderStartSamples
                                      endSamples:renderEndSamples
                                            done:^(UIImage *image) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.image.image = image;
                                                    self.highlightedImage.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                                                    self.highlightedImage.tintColor = self.progressColor;
                                                    if (!image) {
                                                        if (self.completion)
                                                            self.completion(audioURL, NO);
                                                        return;
                                                    }

                                                    self.cachedStartSamples = renderStartSamples;
                                                    self.cachedEndSamples = renderEndSamples;
                                                    [self layoutSubviews]; // warning
                                                    if ([self.delegate respondsToSelector:@selector(waveformViewDidRender:)])
                                                        [self.delegate waveformViewDidRender:self];
                                                    self.renderingInProgress = NO;
                                                    if (self.completion)
                                                        self.completion(audioURL, YES);
                                                });
                                            }];
    });
}

- (void)plotLogGraph:(Float32 *) samples
        maximumValue:(Float32) normalizeMax
         sampleCount:(NSInteger) sampleCount
         imageHeight:(float) imageHeight
                done:(void(^)(UIImage *image))done
{
    CGSize imageSize = CGSizeMake(sampleCount, imageHeight);
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context, 1.0);
    CGContextSetLineWidth(context, FDWSampleSkipCount/2);
    CGContextSetStrokeColorWithColor(context, [self.wavesColor CGColor]);

    float centerLeft = (imageHeight / 2);
    float sampleAdjustmentFactor = imageHeight / (normalizeMax - FDWNoiseFloor) / 2;
    
    for (NSInteger i = 0; i < sampleCount; i++) {
        Float32 sample = *samples++;
        if (i % FDWSampleSkipCount != 0)
            continue;
        float pixels = (sample - FDWNoiseFloor) * sampleAdjustmentFactor;
        CGContextMoveToPoint(context, i, centerLeft-pixels);
        CGContextAddLineToPoint(context, i, centerLeft+pixels);
        CGContextStrokePath(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    done(image);
}

- (void)renderPNGAudioPictogramLogForAsset:(AVURLAsset *)songAsset
                              startSamples:(unsigned long int)start
                                endSamples:(unsigned long int)end
                                      done:(void(^)(UIImage *image))done

{
    // TODO: break out subsampling code
    CGFloat widthInPixels = self.frame.size.width * [UIScreen mainScreen].scale;
    CGFloat heightInPixels = self.frame.size.height * [UIScreen mainScreen].scale;

    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:songAsset error:&error];
    AVAssetTrack *songTrack = [songAsset.tracks objectAtIndex:0];
    NSDictionary *outputSettingsDict = @{
        AVFormatIDKey:@(kAudioFormatLinearPCM),
        AVLinearPCMBitDepthKey: @16,
        AVLinearPCMIsFloatKey: @(NO),
        AVLinearPCMIsBigEndianKey: @(NO),
        AVLinearPCMIsNonInterleaved: @(NO),
    };
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    UInt32 channelCount = 0;
    NSArray *formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (!fmtDesc) return; //!
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    Float32 maximum = FDWNoiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    
    NSInteger downsampleFactor = (end-start) / widthInPixels;
    downsampleFactor = downsampleFactor<1 ? 1 : downsampleFactor;
    NSMutableData *fullSongData = [[NSMutableData alloc] initWithCapacity:self.totalSamples/downsampleFactor*2]; // 16-bit samples
    reader.timeRange = CMTimeRangeMake(CMTimeMake(start, self.asset.duration.timescale), CMTimeMake((end-start), self.asset.duration.timescale));
    [reader startReading];
    
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            void *data = malloc(bufferLength);
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data);
            SInt16 *samples = (SInt16 *) data;
            int sampleCount = (int) bufferLength / bytesPerInputSample;
            for (int i=0; i<sampleCount; i++) {
                Float32 sample = (Float32) *samples++;
                sample = decibel(sample);
                sample = minMaxX(sample, FDWNoiseFloor, 0);
                tally += sample; // Should be RMS?
                for (int j=1; j<channelCount; j++)
                    samples++;
                tallyCount++;
                
                if (tallyCount == downsampleFactor) {
                    sample = tally / tallyCount;
                    maximum = maximum > sample ? maximum : sample;
                    [fullSongData appendBytes:&sample length:sizeof(sample)];
                    tally = 0;
                    tallyCount = 0;
                    outSamples++;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            free(data);
        }
    }

    if (reader.status == AVAssetReaderStatusCompleted) {
        [self plotLogGraph:(Float32 *)fullSongData.bytes
              maximumValue:maximum
               sampleCount:outSamples
               imageHeight:heightInPixels
                      done:done];
    } else {
        if (done)
            done(nil);
    }
}

#pragma mark - Interaction

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panRecognizer])
        return [self doesAllowScrubbing] || [self doesAllowStretchAndScroll];
    else if ([gestureRecognizer isEqual:self.tapRecognizer])
        return [self doesAllowScrubbing];
    else if ([gestureRecognizer isEqual:self.pinchRecognizer])
        return [self doesAllowStretchAndScroll];
    return NO;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (!self.doesAllowStretchAndScroll)
        return;
    if (recognizer.scale == 1) return;
    
    unsigned long middleSamples = (self.zoomStartSamples + self.zoomEndSamples) / 2;
    unsigned long rangeSamples = self.zoomEndSamples - self.zoomStartSamples;
    if (middleSamples - 1/recognizer.scale*rangeSamples/2 >= 0)
        _zoomStartSamples = middleSamples - 1/recognizer.scale*rangeSamples/2;
    else
        _zoomStartSamples = 0;
    if (middleSamples + 1/recognizer.scale*rangeSamples/2 <= self.totalSamples)
        _zoomEndSamples = middleSamples + 1/recognizer.scale*rangeSamples/2;
    else
        _zoomEndSamples = self.totalSamples;
    [self setNeedsDisplay];
    [self setNeedsLayout];
    recognizer.scale = 1;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self];
    NSLog(@"translation: %f", point.x);

    if ([self doesAllowStretchAndScroll]) {
        long translationSamples = (float)(self.zoomEndSamples-self.zoomStartSamples) * point.x / self.bounds.size.width;
        [recognizer setTranslation:CGPointZero inView:self];
        if ((float)self.zoomStartSamples - translationSamples < 0)
            translationSamples = (float)self.zoomStartSamples;
        if ((float)self.zoomEndSamples - translationSamples > self.totalSamples)
            translationSamples = self.zoomEndSamples - self.totalSamples;
        _zoomStartSamples -= translationSamples;
        _zoomEndSamples -= translationSamples;
        [self setNeedsDisplay];
        [self setNeedsLayout];
    } else if ([self doesAllowScrubbing]) {
        self.progressSamples = self.zoomStartSamples + (float)(self.zoomEndSamples-self.zoomStartSamples) * [recognizer locationInView:self].x / self.bounds.size.width;
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (![self doesAllowScrubbing])
        return;
    self.progressSamples = self.zoomStartSamples + (float)(self.zoomEndSamples-self.zoomStartSamples) * [recognizer locationInView:self].x / self.bounds.size.width;
}

@end
