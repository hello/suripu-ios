//
//  HEMPillDfuPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 7/5/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMPillDfuPresenter.h"
#import "HEMDfuService.h"
#import "HEMStyle.h"

@interface HEMPillDfuPresenter()

@property (nonatomic, weak) HEMDfuService* dfuService;
@property (nonatomic, weak) UIButton* actionButton;
@property (nonatomic, weak) UILabel* titleLabel;
@property (nonatomic, weak) UILabel* descriptionLabel;

@end

@implementation HEMPillDfuPresenter

- (instancetype)initWithDfuService:(HEMDfuService*)dfuService {
    self = [super init];
    if (self) {
        _dfuService = dfuService;
    }
    return self;
}

- (void)bindWithTitleLabel:(UILabel*)titleLabel descriptionLabel:(UILabel*)descriptionLabel {
    [titleLabel setFont:[UIFont h5]];
    [titleLabel setTextColor:[UIColor grey6]];
    [descriptionLabel setFont:[UIFont body]];
    [descriptionLabel setTextColor:[UIColor grey5]];
    [self setTitleLabel:titleLabel];
    [self setDescriptionLabel:descriptionLabel];
}

- (void)bindWithActionButton:(UIButton*)actionButton {
    [actionButton addTarget:self
                     action:@selector(checkConditions:)
           forControlEvents:UIControlEventTouchUpInside];
    [self setActionButton:actionButton];
}

#pragma mark - Actions

- (void)checkConditions:(UIButton*)button {
    
}

@end
