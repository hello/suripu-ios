//
//  HEMOnboardingController.h
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"

@interface HEMOnboardingController : HEMBaseController

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;

- (UIBarButtonItem*)cancelItem;
- (void)showCancelButtonWithSelector:(SEL)selector;
- (void)enableBackButton:(BOOL)enable;
- (void)showHelpButton;
- (void)stylePrimaryButton:(UIButton*)button
           secondaryButton:(UIButton*)secondaryButton
              withDelegate:(BOOL)hasDelegate;

@end
