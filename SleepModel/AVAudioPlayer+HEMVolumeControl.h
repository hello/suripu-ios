//
//  AVAudioPlayer+HEMVolumeControl.h
//  Sense
//
//  Created by Jimmy Lu on 4/27/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayer (HEMVolumeControl)

- (BOOL)playWithVolumeFadeOver:(NSTimeInterval)seconds;

@end
