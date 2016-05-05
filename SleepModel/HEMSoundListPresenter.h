//
//  HEMSoundListPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 4/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMListPresenter.h"

@class HEMAudioService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMSoundListPresenter : HEMListPresenter

- (instancetype)initWithTitle:(NSString *)title
                        items:(NSArray *)items
             selectedItemName:(NSString*)selectedItemName
                 audioService:(HEMAudioService*)audioService NS_DESIGNATED_INITIALIZER;

/**
 * @discussion
 * This should be overridden by subclasses to return the currently selected
 * preview url
 *
 * @return the selected sound's preview url
 */
- (nullable NSString*)selectedPreviewUrl;

/**
 * @discussion
 * This should be overridden by subclasses to return whether a given item matches
 * the currently selected preview url, determined from calling selectedPreviewUrl
 *
 * @return YES if item matches.  No otherwise
 */
- (BOOL)item:(id)item matchesCurrentPreviewUrl:(NSString*)currentUrl;

@end

NS_ASSUME_NONNULL_END