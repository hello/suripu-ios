//
//  HEMInsightActionPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 6/23/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENInsight.h>

#import "HEMInsightActionPresenter.h"
#import "HEMActivityCoverView.h"
#import "HEMShareContentProvider.h"
#import "HEMConfirmationView.h"
#import "HEMShareService.h"
#import "HEMStyle.h"

static CGFloat const HEMInsightButtonAnimationDuration = 0.5f;
static CGFloat const HEMInsightButtonContainerBorderWidth = 0.5f;

@interface HEMInsightActionPresenter()

@property (nonatomic, weak) SENInsight* insight;
@property (nonatomic, weak) HEMShareService* shareService;
@property (nonatomic, weak) UIView* buttonContainer;
@property (nonatomic, weak) NSLayoutConstraint* buttonContainerBottomConstraint;
@property (nonatomic, weak) NSLayoutConstraint* shareButtonLeadingConstraint;
@property (nonatomic, weak) NSLayoutConstraint* shareButtonTrailingConstraint;
@property (nonatomic, weak) UIButton* closeButton;
@property (nonatomic, weak) UIButton* shareButton;
@property (nonatomic, weak) UIView* buttonDivider;
@property (nonatomic, weak) UIView* buttonShadowView;
@property (nonatomic, weak) HEMActivityCoverView* activityView;

@end

@implementation HEMInsightActionPresenter

- (instancetype)initWithInsight:(SENInsight*)insight
                   shareService:(HEMShareService*)shareService {
    self = [super init];
    if (self) {
        _insight = insight;
        _shareService = shareService;
    }
    return self;
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    
    [self determineShareability];
    
    [[self buttonShadowView] setHidden:YES];
    [[self buttonContainerBottomConstraint] setConstant:0.0f];
    [UIView animateWithDuration:HEMInsightButtonAnimationDuration animations:^{
        [[self buttonContainer] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [[self buttonShadowView] setHidden:NO];
    }];
}

- (void)willDisappear {
    [super willDisappear];
    [[self shareButtonTrailingConstraint] setActive:NO];
    [[self shareButtonLeadingConstraint] setActive:NO];
}

- (void)didDisappear {
    [super didDisappear];
    
    CGFloat containerHeight = CGRectGetHeight([[self buttonContainer] bounds]);
    [[self buttonContainerBottomConstraint] setConstant:-containerHeight];
}

#pragma mark - Bindings

- (void)bindWithButtonContainer:(UIView*)buttonContainer
                containerShadow:(UIView*)shadowView
           withBottomConstraint:(NSLayoutConstraint*)bottomConstraint {
    [[buttonContainer layer] setBorderWidth:HEMInsightButtonContainerBorderWidth];
    [[buttonContainer layer] setBorderColor:[[UIColor borderColor] CGColor]];
    [bottomConstraint setConstant:-CGRectGetHeight([buttonContainer bounds])];
    [self setButtonContainer:buttonContainer];
    [self setButtonShadowView:shadowView];
    [self setButtonContainerBottomConstraint:bottomConstraint];
}

- (void)bindWithCloseButton:(UIButton*)closeButton
                shareButton:(UIButton*)shareButton
     shareLeadingConstraint:(NSLayoutConstraint*)leadingConstraint
    shareTrailingConstraint:(NSLayoutConstraint*)trailingConstraint
     andViewThatDividesThem:(UIView*)divider {
    [shareButton setBackgroundColor:[UIColor whiteColor]];
    [[shareButton titleLabel] setFont:[UIFont insightDismissButtonFont]];
    [shareButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [shareButton addTarget:self
                    action:@selector(shareInsight)
          forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setBackgroundColor:[UIColor whiteColor]];
    [[closeButton titleLabel] setFont:[UIFont insightDismissButtonFont]];
    [closeButton setTitleColor:[UIColor grey4] forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(closeInsight)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self setShareButtonTrailingConstraint:trailingConstraint];
    [self setShareButtonLeadingConstraint:leadingConstraint];
    [self setCloseButton:closeButton];
    [self setShareButton:shareButton];
    [self setButtonDivider:divider];
}

#pragma mark - Hide / Show Sharing

- (void)determineShareability {
    if (![[self shareService] isShareable:[self insight]]) {
        [[self buttonDivider] setHidden:YES];
        
        CGFloat shareWidth = CGRectGetWidth([[self shareButton] bounds]);
        [[self shareButtonLeadingConstraint] setConstant:shareWidth];
        [[self buttonContainer] layoutIfNeeded];
        [[self shareButton] setHidden:YES];
    }
}

#pragma mark - Actions

- (void)closeInsight {
    [[self delegate] dismissInsightFrom:self];
}

- (void)shareInsight {
    DDLogVerbose(@"sharing insight");
    UIView* containerView = [[self buttonContainer] superview];
    HEMActivityCoverView* coverView = [HEMActivityCoverView transparentCoverView];
    [coverView showInView:containerView activity:YES completion:nil];
    [self setActivityView:coverView];
    
    __weak typeof(self) weakSelf = self;
    [[self shareService] shareUrlFor:[self insight] completion:^(NSString *url, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (url) {
            [strongSelf showShareOptionsWithUrl:url forType:[[strongSelf insight] shareType]];
        } else {
            void(^showError)(void) = ^(void){
                NSString* title = NSLocalizedString(@"share.error.no-link.title", nil);
                NSString* message = NSLocalizedString(@"share.error.no-link.message", nil);
                [[strongSelf delegate] presentErrorWithTitle:title
                                                     message:message
                                               fromPresenter:strongSelf];
            };
            [[strongSelf activityView] dismissWithResultText:nil
                                             showSuccessMark:NO
                                                      remove:YES
                                                  completion:showError];
        }
    }];
}

// TODO: consolidate logic with HEMInsightsFeedPresenter, or any sharing logic
// recommend adding common presenter delegate and potentially making a category
// for presenter to show sharing options
- (void)showShareOptionsWithUrl:(NSString*)url forType:(NSString*)type {
    [[self activityView] dismissWithResultText:nil showSuccessMark:NO remove:YES completion:^{
        [self setActivityView:nil];
    }];
    
    HEMShareContentProvider* insightShareContent = [[HEMShareContentProvider alloc] initWithItemToShare:url forType:type];
    
    UIActivityViewController* shareVC =
    [[UIActivityViewController alloc] initWithActivityItems:@[insightShareContent]
                                      applicationActivities:nil];
    
    __weak typeof(self) weakSelf = self;
    [shareVC setCompletionWithItemsHandler:^(NSString * activityType, BOOL completed, NSArray * returnedItems, NSError * activityError){
        // facebook sharing has it's own posted confirmation
        if (!completed || [activityType isEqualToString:UIActivityTypePostToFacebook]) {
            return;
        }
        
        if (activityError) {
            [SENAnalytics trackError:activityError];
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString* text = NSLocalizedString(@"status.shared", nil);
        HEMConfirmationLayout layout = HEMConfirmationLayoutVertical;
        if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
            text = NSLocalizedString(@"status.copied", nil);
            layout = HEMConfirmationLayoutHorizontal;
        }
        
        UIView* containerView = [[strongSelf buttonContainer] superview];
        HEMConfirmationView* confirmView = [[HEMConfirmationView alloc] initWithText:text layout:layout];
        [confirmView showInView:containerView];
    }];
    
    [[self delegate] presentController:shareVC fromPresenter:self];
}

@end
