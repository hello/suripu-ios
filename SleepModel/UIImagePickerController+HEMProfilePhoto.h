//
//  UIImagePickerController+HEMProfilePhoto.h
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImagePickerController (HEMProfilePhoto)

+ (instancetype)photoPickerWithCamera:(BOOL)camera
                             delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END