//
//  UIImagePickerController+HEMProfilePhoto.m
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

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

+ (HEMProfilePhotoAccess)authorizationForCamera {
    NSString* cameraType = AVMediaTypeVideo;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:cameraType]; // yes, video
    switch (status) {
        case AVAuthorizationStatusAuthorized:
            return HEMProfilePhotoAccessAuthorized;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            return HEMProfilePhotoAccessDenied;
            break;
        case AVAuthorizationStatusNotDetermined:
        default:
            return HEMProfilePhotoAccessUnknown;
    }
}

+ (void)promptForCameraAccessIfNeeded:(HEMProfilePhotoAccessHandler)completion {
    HEMProfilePhotoAccess access = [self authorizationForCamera];
    switch (access) {
        case HEMProfilePhotoAccessUnknown: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                completion (granted ? HEMProfilePhotoAccessAuthorized : HEMProfilePhotoAccessDenied);
            }];
            break;
        }
        default:
            completion (access);
            break;
    }
}

@end
