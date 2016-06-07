//
//  UIImagePickerController+HEMProfilePhoto.m
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>

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

+ (void)promptForAccessIfNeededFor:(BOOL)camera completion:(HEMProfilePhotoAccessHandler)completion {
    if (camera) {
        [self promptForCameraAccessIfNeeded:completion];
    } else {
        [self promptForCameraRollAccessIfNeeded:completion];
    }
}

+ (HEMProfilePhotoAccess)authorizationFor:(BOOL)camera {
    if (camera) {
        return [self authorizationForCamera];
    } else {
        return [self authorizationForCameraRoll];
    }
}

#pragma mark - Camera

+ (HEMProfilePhotoAccess)authorizationForCamera {
    NSString* cameraType = AVMediaTypeVideo; // yes, video
    switch ([AVCaptureDevice authorizationStatusForMediaType:cameraType]) {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion (granted ? HEMProfilePhotoAccessAuthorized : HEMProfilePhotoAccessDenied);
                });
            }];
            break;
        }
        default:
            completion (access);
            break;
    }
}

#pragma mark - Photo Library

+ (HEMProfilePhotoAccess)authorizationForCameraRoll {
    switch ([PHPhotoLibrary authorizationStatus]) {
        case PHAuthorizationStatusAuthorized:
            return HEMProfilePhotoAccessAuthorized;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            return HEMProfilePhotoAccessDenied;
        case PHAuthorizationStatusNotDetermined:
        default:
            return HEMProfilePhotoAccessUnknown;
    }
}

+ (void)promptForCameraRollAccessIfNeeded:(HEMProfilePhotoAccessHandler)completion {
    HEMProfilePhotoAccess access = [self authorizationForCameraRoll];
    switch (access) {
        case HEMProfilePhotoAccessUnknown: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion (status == PHAuthorizationStatusAuthorized ?
                                HEMProfilePhotoAccessAuthorized :
                                HEMProfilePhotoAccessDenied);
                });
            }];
            break;
        }
        default:
            completion (access);
            break;
    }
}

@end
