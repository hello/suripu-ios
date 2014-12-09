//
//  HEMEventInfoView.h
//  Sense
//
//  Created by Delisa Mason on 10/8/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMPaddedRoundedLabel;
@class FDWaveformView;
@class RTSpinKitView;

typedef NS_ENUM(NSUInteger, HEMEventInfoViewCaretPosition) {
    HEMEventInfoViewCaretPositionTop,
    HEMEventInfoViewCaretPositionMiddle,
    HEMEventInfoViewCaretPositionBottom,
};

@interface HEMEventInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet UIButton* playSoundButton;
@property (weak, nonatomic) IBOutlet FDWaveformView* waveformView;
@property (weak, nonatomic) IBOutlet RTSpinKitView* spinnerView;
@property (nonatomic) HEMEventInfoViewCaretPosition caretPosition;
@property (weak, nonatomic) IBOutlet UIButton *verifyDataButton;
@property (strong, nonatomic, readonly) NSDictionary* markdownAttributes;
@property (strong, nonatomic, readonly) NSDateFormatter* timestampDateFormatter;

- (void)showAudioPlayer:(BOOL)isVisible;
- (void)setAudioURL:(NSURL*)audioURL;
- (IBAction)toggleAudio;
- (void)stopAudio;
- (void)playAudio;

- (void)setLoading:(BOOL)isLoading;
@end
