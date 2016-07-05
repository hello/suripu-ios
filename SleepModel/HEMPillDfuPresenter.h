//
//  HEMPillDfuPresenter.h
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPresenter.h"

@class HEMDfuService;

NS_ASSUME_NONNULL_BEGIN

@interface HEMPillDfuPresenter : HEMPresenter

- (instancetype)initWithDfuService:(HEMDfuService*)dfuService;
- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel;
- (void)bindWithActionButton:(UIButton*)actionButton;

@end

NS_ASSUME_NONNULL_END