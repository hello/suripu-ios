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

- (NSUInteger)numberOfFieldsIn:(HEMFormViewController*)formViewController;
- (NSString*)placeHolderTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;
- (NSString*)defaultTextIn:(HEMFormViewController*)formViewController atIndex:(NSUInteger)index;

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

@end

@interface HEMFormViewController : UIViewController

@property (weak, nonatomic) id<HEMFormViewControllerDelegate> delegate;

@end
