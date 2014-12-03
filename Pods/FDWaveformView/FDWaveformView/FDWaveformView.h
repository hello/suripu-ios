//
//  FDWaveformView
//
//  Created by William Entriken on 10/6/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^FDWDrawingCompletionBlock)(NSURL* url, BOOL success);

@protocol FDWaveformViewDelegate;

@interface FDWaveformView : UIView
@property (nonatomic, weak) id<FDWaveformViewDelegate> delegate;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, assign, readonly) unsigned long int totalSamples;
@property (nonatomic, assign) unsigned long int progressSamples;
@property (nonatomic, assign) unsigned long int zoomStartSamples;
@property (nonatomic, assign) unsigned long int zoomEndSamples;
@property (nonatomic, getter=doesAllowScrubbing) BOOL allowScrubbing;
@property (nonatomic, getter=doesAllowStretchAndScroll) BOOL allowStretchAndScroll;
@property (nonatomic, copy) UIColor *wavesColor;
@property (nonatomic, copy) UIColor *progressColor;
@property (nonatomic, copy) FDWDrawingCompletionBlock completion;

- (void)setProgressRatio:(CGFloat)progressRatio;
@end

@protocol FDWaveformViewDelegate <NSObject>
@optional
- (void)waveformViewWillRender:(FDWaveformView *)waveformView;
- (void)waveformViewDidRender:(FDWaveformView *)waveformView;
- (void)waveformViewWillLoad:(FDWaveformView *)waveformView;
- (void)waveformViewDidLoad:(FDWaveformView *)waveformView;
- (void)waveformViewDidFail:(FDWaveformView *)waveformView error:(NSError*)error;
@end