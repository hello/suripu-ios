//
//  HEMInsightActionPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 6/23/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMInsightActionPresenter;
@class HEMShareService;

NS_ASSUME_NONNULL_BEGIN

@protocol HEMInsightActionDelegate <NSObject>

- (void)dismissInsightFrom:(HEMInsightActionPresenter*)presenter;
- (void)presentController:(UIViewController*)controller
            fromPresenter:(HEMInsightActionPresenter*)presenter;
- (void)presentErrorWithTitle:(NSString*)title
                      message:(NSString*)message
                fromPresenter:(HEMInsightActionPresenter*)presenter;

@end

@interface HEMInsightActionPresenter : HEMPresenter

@property (nonatomic, weak) id<HEMInsightActionDelegate> delegate;

- (instancetype)initWithInsight:(SENInsight*)insight
                   shareService:(HEMShareService*)shareService;

- (void)bindWithButtonContainer:(UIView*)buttonContainer
                containerShadow:(nullable UIView*)shadowView
           withBottomConstraint:(NSLayoutConstraint*)bottomConstraint;

- (void)bindWithCloseButton:(UIButton*)closeButton
                shareButton:(UIButton*)shareButton
     shareLeadingConstraint:(NSLayoutConstraint*)leadingConstraint
    shareTrailingConstraint:(NSLayoutConstraint*)trailingConstraint
     andViewThatDividesThem:(UIView*)divider;

@end

NS_ASSUME_NONNULL_END