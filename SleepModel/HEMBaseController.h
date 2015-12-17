//
//  HEMBaseController.h
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMNavigationShadowView.h"

@class HEMPresenter;

NS_ASSUME_NONNULL_BEGIN

@interface HEMBaseController : UIViewController

@property (nonatomic, strong, readonly) HEMNavigationShadowView* shadowView;
@property (nullable, nonatomic, strong, readonly) NSArray<HEMPresenter*>* presenters;

- (void)addPresenter:(HEMPresenter*)presenter;

/**
 * @discussion
 * Subclasses should override this value if a shadow view underneath the navigation
 * bar should never be shown.  Defaults to YES
 *
 * @return YES to show the shadow view, NO otherwise
 */
- (BOOL)wantsShadowView;

@end

NS_ASSUME_NONNULL_END
