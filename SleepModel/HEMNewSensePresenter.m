//
//  HEMNewSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMNewSensePresenter.h"
#import "HEMStyle.h"

@implementation HEMNewSensePresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {}

- (void)bindWithNavigationItem:(UINavigationItem*)navItem {}

- (void)bindWithNextButton:(UIButton*)nextButton {}

- (void)bindWithNeedButton:(UIButton*)needButton {
    [needButton setTitleColor:[UIColor tintColor] forState:UIControlStateNormal];
    [[needButton titleLabel] setFont:[UIFont secondaryButtonFont]];
}

@end
