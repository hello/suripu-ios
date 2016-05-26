//
//  UIAlertController+HEMPhotoOptions.h
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HEMPhotoAction)(void);

@interface UIAlertController (HEMPhotoOptions)

+ (instancetype)photoOptionActionSheet;
- (void)addRemovePhotoAction:(HEMPhotoAction)action;
- (void)addFacebookImportAction:(HEMPhotoAction)action;
- (void)addCameraActionIfSupported:(HEMPhotoAction)action;
- (void)addCameraRollAction:(HEMPhotoAction)action;

@end

NS_ASSUME_NONNULL_END