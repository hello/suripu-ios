//
//  HEMEmbeddedVideoView.h
//  Sense
//
//  Created by Jimmy Lu on 8/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMEmbeddedVideoView : UIView

@property (nonatomic, assign, getter=isReady) BOOL ready;

- (void)setVideoPath:(NSString*)videoPath;
- (void)setFirstFrame:(UIImage*)image videoPath:(NSString*)videoPath;
- (void)playVideoWhenReady;
- (void)stop;

@end
