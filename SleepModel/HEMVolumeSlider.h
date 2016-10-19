//
//  HEMVolumeSlider.h
//  Sense
//
//  Created by Jimmy Lu on 10/18/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMVolumeSlider;

@protocol HEMVolumeChangeDelegate

- (void)didChangeVolumeTo:(NSInteger)volume fromSlider:(HEMVolumeSlider*)slider;

@end

@interface HEMVolumeSlider : UIView

@property (nonatomic, weak) id<HEMVolumeChangeDelegate> changeDelegate;
@property (nonatomic, strong) UIColor* highlightColor;
@property (nonatomic, strong) UIColor* normalColor;
@property (nonatomic, assign) NSInteger currentVolume;
@property (nonatomic, assign) NSInteger maxVolumeLevel;

- (BOOL)isRendered;
- (void)render;

@end
