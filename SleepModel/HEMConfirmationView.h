//
//  HEMConfirmationView.h
//  Sense
//
//  Created by Jimmy Lu on 6/22/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HEMConfirmationLayout) {
    HEMConfirmationLayoutHorizontal = 1,
    HEMConfirmationLayoutVertical
};

NS_ASSUME_NONNULL_BEGIN

@interface HEMConfirmationView : UIView

- (instancetype)initWithText:(NSString*)text layout:(HEMConfirmationLayout)layout;
- (void)showInView:(UIView*)view;

@end

NS_ASSUME_NONNULL_END