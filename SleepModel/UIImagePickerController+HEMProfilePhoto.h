//
//  UIImagePickerController+HEMProfilePhoto.h
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HEMProfilePhotoAccess) {
    HEMProfilePhotoAccessUnknown = 1,
    HEMProfilePhotoAccessAuthorized,
    HEMProfilePhotoAccessDenied
};

typedef void(^HEMProfilePhotoAccessHandler)(HEMProfilePhotoAccess access);

@interface UIImagePickerController (HEMProfilePhoto)

+ (instancetype)photoPickerWithCamera:(BOOL)camera
                             delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

+ (void)promptForAccessIfNeededFor:(BOOL)camera completion:(HEMProfilePhotoAccessHandler)completion;
+ (HEMProfilePhotoAccess)authorizationFor:(BOOL)camera;

@end

NS_ASSUME_NONNULL_END