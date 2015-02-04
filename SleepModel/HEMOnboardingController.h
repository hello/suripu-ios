//
//  HEMOnboardingController.h
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"

@class SENSenseManager;

@interface HEMOnboardingController : HEMBaseController

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;

- (UIBarButtonItem*)cancelItem;
- (SENSenseManager*)manager;
- (void)showCancelButtonWithSelector:(SEL)selector;
- (void)enableBackButton:(BOOL)enable;
- (void)showHelpButtonForStep:(NSString*)stepName;
- (void)stylePrimaryButton:(UIButton*)button
           secondaryButton:(UIButton*)secondaryButton
              withDelegate:(BOOL)hasDelegate;
- (void)showActivityWithMessage:(NSString*)message
                     completion:(void(^)(void))completion;
- (void)stopActivityWithMessage:(NSString*)message
                        success:(BOOL)sucess
                     completion:(void(^)(void))completion;
- (void)updateActivityText:(NSString*)updateMessage
                completion:(void(^)(BOOL finished))completion;

@end
