//
//  HEMURLImageView.h
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMURLImageCallback)(UIImage* _Nullable image, NSString* _Nullable url, NSError* _Nullable error);

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
 * for this view.  This uses a default timeout.
 *
 * @param url:        the url to the image
 * @param completion: the callback to invoke when image has been downloaded / loaded.
 *                    If url is the same as the currentImageURL, params will be nil
 */
- (void)setImageWithURL:(NSString *)url completion:(HEMURLImageCallback)completion;

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
 * download the image, if not cached, and set the returned image as the image
 * for this view
 *
 * @param url:        the url to the image
 * @param timeout:    specify the timeout for the request when downloading the image
 * @param completion: the callback to invoke when image has been downloaded / loaded.
 *                    If url is the same as the currentImageURL, params will be nil
 */
- (void)setImageWithURL:(nullable NSString *)url
            withTimeout:(NSTimeInterval)timeout
             completion:(nullable HEMURLImageCallback)completion;

/**
 * @discussion
 * cancel the image download, if not finished or cancelled.  Upon deallocation
 * of this instance, it will automatically cancel the operation as well.
 */
- (void)cancelImageDownload;

/**
 * @discussion
 * Call to reset the image view in to a default state
 */
- (void)resetState;

/**
 * @discussion
 * Users of this view should not call this method directly, but instead should
 * call one of the setImageWithURL: methods.  Sub classes should override this
 * as needed to receive a call back when the download begins and is complete
 *
 * @param request: the download request
 * @param completion: the block to call upon completion, failure or not
 */
- (void)downloadAndLoadImageFrom:(NSURLRequest*)request
                      completion:(HEMURLImageCallback)completion;

@end

NS_ASSUME_NONNULL_END