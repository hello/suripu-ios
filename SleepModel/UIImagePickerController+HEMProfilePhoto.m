//
//  UIImagePickerController+HEMProfilePhoto.m
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIImagePickerController+HEMProfilePhoto.h"

@implementation UIImagePickerController (HEMProfilePhoto)

+ (instancetype)photoPickerWithCamera:(BOOL)camera
                             delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate {
    UIImagePickerController* picker = [self new];
    [picker setAllowsEditing:YES];
    [picker setDelegate:delegate];
    
    if (camera) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setShowsCameraControls:YES];
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            [picker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
        } else {
            [picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
        }
    } else {
        [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    
    return picker;
}

@end
