//
//  HEMOnboardingController.h
//  Sense
//
//  Created by Jimmy Lu on 1/11/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMBaseController.h"
#import "HEMOnboardingService.h"

@class SENSenseManager;

@interface HEMOnboardingController : HEMBaseController

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;

@property (assign, nonatomic, readonly, getter=isVisible) BOOL visible;

/**
 * @param checkpoint: the onboarding checkpoint
 * @param force: YES to force the checkpoint, regardless of account state
 * @return the controller to show for the specified checkpoint
 */
+ (UIViewController*)controllerForCheckpoint:(HEMOnboardingCheckpoint)checkpoint
                                       force:(BOOL)force;

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

/**
 * @method
 * Apply common 'description' attributed string attributes to the existing string.
 * If the supplied attrText has already added attributes that this method applies,
 * it will remain as is and this method will not override them.
 *
 * @param attrText: the attributed text to apply common attributes to
 */
- (void)applyCommonDescriptionAttributesTo:(NSMutableAttributedString*)attrText;

/**
 * @method
 * Convenience method to turn the text in to the properly bolded attributed text
 * by constructing an attributed string with the proper "bold" font attribute.  The
 * size of the font used is the same as the common description attributes
 *
 * @param text: the text to bold
 * @return bolded attributed text
 */
- (NSAttributedString*)boldAttributedText:(NSString*)text;

/**
 * @method
 * Convenience method to turn the specified text in an attributed string with the
 * text 'bolded' with the color given
 *
 * @param text: the text to bold and color
 * @return bolded and colored attributed text
 */
- (NSAttributedString*)boldAttributedText:(NSString *)text withColor:(UIColor*)color;

- (void)completeOnboarding;

@end
