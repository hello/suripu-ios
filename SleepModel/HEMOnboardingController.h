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

@property (assign, nonatomic, readonly, getter=isVisible) BOOL visible;

- (UIBarButtonItem*)cancelItem;
- (SENSenseManager*)manager;
- (void)showCancelButtonWithSelector:(SEL)selector;
- (void)enableBackButton:(BOOL)enable;
- (void)showHelpButtonForPage:(NSString*)page
         andTrackWithStepName:(NSString*)stepName;
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

/**
 * Some onboarding controllers are reused inside the main app, but analytics
 * events need to differ.  For such controllers, call this convenience method
 * to track the event, which will conditionally append 'Onboarding ' prefix
 * to the event
 *
 * @param event: the name of the event as if it's not for onboarding.  Prefix will
 *               be added as needed
 */
- (void)trackAnalyticsEvent:(NSString*)event;

/**
 * Some onboarding controllers are reused inside the main app, but analytics
 * events need to differ.  For such controllers, call this convenience method
 * to track the event, which will conditionally append 'Onboarding ' prefix
 * to the event
 *
 * @param event:      the name of the event as if it's not for onboarding.  Prefix will
 *                    be added as needed
 * @param properties: the properties to associate with the event
 */
- (void)trackAnalyticsEvent:(NSString *)event properties:(NSDictionary*)properties;

@end
