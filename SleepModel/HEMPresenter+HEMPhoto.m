//
//  HEMPresenter+HEMPhoto.m
//  Sense
//
//  Created by Jimmy Lu on 6/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter+HEMPhoto.h"
#import "HEMAlertViewController.h"

@implementation HEMPresenter (HEMPhoto)

- (HEMAlertViewController*)settingsPromptForCamera:(BOOL)camera {
    NSString* title = nil, *message = nil;
    if (camera) {
        title = NSLocalizedString(@"account.photo.enable-camera.title", nil);
        message = NSLocalizedString(@"account.photo.enable-camera.message", nil);
    } else {
        title = NSLocalizedString(@"account.photo.enable-camera-roll.title", nil);
        message = NSLocalizedString(@"account.photo.enable-camera-roll.message", nil);
    }
    
    HEMAlertViewController* alert = [[HEMAlertViewController alloc] initWithTitle:title message:message];
    [alert addButtonWithTitle:NSLocalizedString(@"actions.go-to-settings", nil)
                        style:HEMAlertViewButtonStyleRoundRect
                       action:^{
                           UIApplication* app = [UIApplication sharedApplication];
                           [app openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                       }];
    
    return alert;
}

@end
