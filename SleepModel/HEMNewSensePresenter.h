//
//  HEMNewSensePresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMNewSensePresenter;

@protocol HEMNewSenseActionDelegate <NSObject>

- (void)shouldDismissFrom:(HEMNewSensePresenter*)presenter;
- (void)shouldOpenPageTo:(NSString*)page from:(HEMNewSensePresenter*)presenter;
- (void)shouldProceedFrom:(HEMNewSensePresenter*)presenter;

@end

@interface HEMNewSensePresenter : HEMPresenter

@property (nonatomic, weak) id<HEMNewSenseActionDelegate> actionDelegate;

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithNavigationItem:(UINavigationItem*)navItem;
- (void)bindWithNextButton:(UIButton*)nextButton;
- (void)bindWithNeedButton:(UIButton*)needButton;
- (void)bindWithIllustrationView:(UIImageView*)illustrationView;

@end
