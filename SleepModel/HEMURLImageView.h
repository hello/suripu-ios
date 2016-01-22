//
//  HEMURLImageView.h
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMURLImageView : UIImageView

/**
 * @discussion
 * the current image url referenced, if any
 */
@property (nonatomic, copy, readonly, nullable) NSString* currentImageURL;

/**
 * @discussion
 * 
 * Optionally display an activity indicator while image is being downloaded.
 * Defaults to YES
 */
@property (nonatomic, assign) BOOL indicateActivity;

/**
 * @discussion
 * Initialize the image view with the given image url
 *
 * @param url: the url to the image
 */
- (nonnull instancetype)initWithImageURL:(nullable NSString*)url;

/**
 * @discussion
 * download the image, if not cached, and set the returned image as the image
 * for this view.  This uses a default timeout.
 *
 * @param url: the url to the image
 */
- (void)setImageWithURL:(nullable NSString*)url;

/**
 * @discussion
 * download the image, if not cached, and set the returned image as the image
 * for this view
 *
 * @param url:     the url to the image
 * @param timeout: specify the timeout for the request when downloading the image
 */
- (void)setImageWithURL:(nullable NSString *)url withTimeout:(NSTimeInterval)timeout;

/**
 * @discussion
 * cancel the image download, if not finished or cancelled.  Upon deallocation
 * of this instance, it will automatically cancel the operation as well.
 */
- (void)cancelImageDownload;

@end
