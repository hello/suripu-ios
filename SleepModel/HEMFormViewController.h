//
//  HEMFormViewController.h
//  Sense
//
//  Created by Jimmy Lu on 5/29/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMFormViewController;

@protocol HEMFormViewControllerDelegate <NSObject>

/**
 *
 * @method numberOfFieldsIn:
 *
 * @discussion
 * Return the number of fields that should show up in the form
 * 
 * @param formViewController: the controller that manages the form
 * @return number of fields in the form
 */
- (NSUInteger)numberOfFieldsIn:(HEMFormViewController*)formViewController;

/**
 * @discussion
 * Return the place holder text that should be displayed in the field at the
 * given index based on numberOfFieldsIn:.
 *
 * The placeHolder text is also used to return the form content when delegate is
 * asked to save the content.  This is required
 *
 * @param formViewController: the controller that manages the form
 * @param index: the index of the field in the form
 * @return place holder text
 */
- (NSString*)placeHolderTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;

/**
 * Save the form content represented by the dictionary.  This is only called if
 * the form was modified, even if it was modified to the same content as it was
 * originally displayed.
 *
 * @param content:            A dictionary where the key is the place holder text 
 *                            in the field within the form and the value  is the 
 *                            text in the field.
 * @param formViewController: this controller
 * @param completion:         when done, delegate should make a callback to the 
 *                            completion block
 */
- (void)saveFormContent:(NSDictionary*)content
                   from:(HEMFormViewController*)formViewController
             completion:(void(^)(NSString* errorMessage))completion;

@optional
- (NSString*)titleForForm:(HEMFormViewController*)formViewController;
- (NSString*)defaultTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;;
- (UIKeyboardType)keyboardTypeForFieldIn:(HEMFormViewController*)formViewController
                                 atIndex:(NSUInteger)index;
- (BOOL)shouldFieldBeSecureIn:(HEMFormViewController*)formViewController
                      atIndex:(NSUInteger)index;

@end

@interface HEMFormViewController : UIViewController

@property (weak, nonatomic) id<HEMFormViewControllerDelegate> delegate;

@end
