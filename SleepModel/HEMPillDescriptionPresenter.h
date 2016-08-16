//
//  HEMPairPillPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 8/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@interface HEMPillDescriptionPresenter : HEMPresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel;

- (void)bindWithContinueButton:(UIButton*)continueButton;

- (void)bindWithLaterButton:(UIButton*)laterButton;

@end
