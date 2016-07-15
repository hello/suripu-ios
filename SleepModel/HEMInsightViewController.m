//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightViewController.h"
#import "HEMInsightsService.h"
#import "HEMInsightPresenter.h"
#import "HEMInsightActionPresenter.h"
#import "HEMShareService.h"

@interface HEMInsightViewController() <HEMInsightActionDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *buttonShadow;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *buttonDivider;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareButtonTrailingConstraint;

@property (strong, nonatomic) HEMShareService* shareService;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
    [SENAnalytics track:kHEMAnalyticsEventInsight];
}

- (void)configurePresenters {
    if (![self insightService]) {
        [self setInsightService:[HEMInsightsService new]];
    }

    HEMInsightPresenter* presenter = [[HEMInsightPresenter alloc] initWithInsightService:[self insightService]
                                                                              forInsight:[self insight]];
    [presenter bindWithCollectionView:[self contentView] withImageColor:[self imageColor]];
    [presenter bindWithButtonShadow:[self buttonShadow]];
    
    HEMShareService* shareService = [HEMShareService new];
    HEMInsightActionPresenter* actionPresenter
        = [[HEMInsightActionPresenter alloc] initWithInsight:[self insight]
                                                shareService:shareService];
    [actionPresenter bindWithButtonContainer:[self buttonContainer]
                             containerShadow:[self buttonShadow]
                        withBottomConstraint:[self buttonContainerBottomConstraint]];
    [actionPresenter bindWithCloseButton:[self doneButton]
                             shareButton:[self shareButton]
                  shareLeadingConstraint:[self shareButtonLeadingConstraint]
                 shareTrailingConstraint:[self shareButtonTrailingConstraint]
                  andViewThatDividesThem:[self buttonDivider]];
    [actionPresenter setDelegate:self];
    
    [self addPresenter:presenter];
    [self addPresenter:actionPresenter];
    [self setShareService:shareService];
}

- (void)closeInsightFromPresenter:(HEMInsightPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HEMInsightActionDelegate

- (void)dismissInsightFrom:(HEMInsightActionPresenter *)presenter {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentErrorWithTitle:(NSString *)title
                      message:(NSString *)message
                fromPresenter:(HEMInsightActionPresenter *)presenter {
    [self showMessageDialog:message title:title];
}

- (void)presentController:(UIViewController *)controller fromPresenter:(HEMInsightActionPresenter *)presenter {
    [self presentViewController:controller animated:YES completion:nil];
}

@end
