//
//  HEMEventBubbleView.h
//  Sense
//
//  Created by Delisa Mason on 5/21/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMEventBubbleWaveformHeight;

@interface HEMEventBubbleView : UIView

+ (CGSize)sizeWithAttributedText:(NSAttributedString *)text timeText:(NSAttributedString *)time showWaveform:(BOOL)visible;

- (void)setMessageText:(NSAttributedString *)message timeText:(NSAttributedString *)time;
- (void)setHighlighted:(BOOL)highlighted;
- (void)showWaveformViews:(BOOL)visible;

@property (nonatomic, getter=isShowingWaveforms, readonly) BOOL showingWaveforms;
@end
