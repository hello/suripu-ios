//
//  HEMPresenter+HEMPhoto.h
//  Sense
//
//  Created by Jimmy Lu on 6/6/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMAlertViewController;

@interface HEMPresenter (HEMPhoto)

- (HEMAlertViewController*)settingsPromptForCamera:(BOOL)camera;

@end
