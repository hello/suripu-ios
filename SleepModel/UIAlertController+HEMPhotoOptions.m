//
//  UIAlertController+HEMPhotoOptions.m
//  Sense
//
//  Created by Jimmy Lu on 5/24/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "UIAlertController+HEMPhotoOptions.h"

@implementation UIAlertController (HEMPhotoOptions)

+ (instancetype)photoOptionActionSheet {
    UIAlertController* alertVC =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSString* cancelText = NSLocalizedString(@"actions.cancel", nil);
    [alertVC addAction:[self actionWithText:cancelText
                                      style:UIAlertActionStyleCancel
                                     action:^{}]];
    
    return alertVC;
}

+ (UIAlertAction*)actionWithText:(NSString*)text
                           style:(UIAlertActionStyle)style
                          action:(HEMPhotoAction)actionBlock {
    return [UIAlertAction actionWithTitle:text
                                    style:style
                                  handler:^(UIAlertAction * _Nonnull action) {
                                      actionBlock();
                                  }];
}

- (void)addRemovePhotoAction:(HEMPhotoAction)action {
    NSString* remove = NSLocalizedString(@"actions.remove-photo", nil);
    [self addAction:[[self class] actionWithText:remove
                                           style:UIAlertActionStyleDestructive
                                          action:action]];
}

- (void)addFacebookImportAction:(HEMPhotoAction)action {
    NSString* facebook = NSLocalizedString(@"actions.import.from.fb", nil);
    [self addAction:[[self class] actionWithText:facebook
                                           style:UIAlertActionStyleDefault
                                          action:action]];
}

- (void)addCameraActionIfSupported:(HEMPhotoAction)action {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSString* camera = NSLocalizedString(@"actions.take.photo", nil);
        [self addAction:[[self class] actionWithText:camera
                                               style:UIAlertActionStyleDefault
                                              action:action]];
    }
}

- (void)addCameraRollAction:(HEMPhotoAction)action {
    NSString* cameraRoll = NSLocalizedString(@"actions.camera-roll", nil);
    [self addAction:[[self class] actionWithText:cameraRoll
                                           style:UIAlertActionStyleDefault
                                          action:action]];
}

@end
