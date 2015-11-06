//
//  HEMEmbeddedVideoView.h
//  Sense
//
//  Created by Jimmy Lu on 8/28/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * View to display the an image, representing the first frame of an embedded
 * video while the actual video is being downloaded and being prepared.
 */
@interface HEMEmbeddedVideoView : UIView

/**
 * @param ready: YES if video, if set, can play when ready.  NO if it's not yet
 *               ready, even if video is ready to play
 */
@property (nonatomic, assign, getter=isReady) BOOL ready;

/**
 * @param loop: YES to loop the video when it's done.  No otherwise.  Defaults
 *              to YES
 */
@property (nonatomic, assign) BOOL loop;

/**
 * @method setVideoPath:
 *
 * @discussion
 * Set the path to the video, local or remote.  This does not automatically start
 * the video.  To play the video, set the ready flag and call playVideoWhenReady.
 *
 * @see ready
 * @see playVideoWhenReady
 *
 * @param videoPath: local or remote path to the video to play
 */
- (void)setVideoPath:(NSString*)videoPath;

/**
 * @method setFirstFrame:videoPath:
 *
 * @discussion
 * If instantiating the view programatically, set the image that represents the
 * first frame of the embedded video and the path to the video, local or remote.
 *
 * @see ready
 * @see playVideoWhenReady
 *
 * @param image:     the image representing the first frame of the image
 * @param videoPath: local or remote path to the video to play
 */
- (void)setFirstFrame:(UIImage*)image videoPath:(NSString*)videoPath;

/**
 * @method playVideoWhenReady
 *
 * @discussion
 * Play the video when everything is ready.
 */
- (void)playVideoWhenReady;

/**
 * @method pause
 *
 * @discussion
 * Pause the video if playing
 */
- (void)pause;

/**
 * @method stop
 *
 * @discussion
 * Stop the video if playing
 */
- (void)stop;

@end
