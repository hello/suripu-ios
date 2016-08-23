//
//  HEMUpgradeSensePresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "UIBarButtonItem+HEMNav.h"

#import "HEMUpgradeSensePresenter.h"
#import "HEMBluetoothUtils.h"

@implementation HEMUpgradeSensePresenter

- (void)bindWithTitleLabel:(UILabel*)titleLabel
          descriptionLabel:(UILabel*)descriptionLabel {
    [super bindWithTitleLabel:titleLabel descriptionLabel:descriptionLabel];
    
    [titleLabel setText:NSLocalizedString(@"upgrade.new-sense.title", nil)];
    [descriptionLabel setText:NSLocalizedString(@"upgrade.new-sense.desc", nil)];
}

- (void)bindWithNavigationItem:(UINavigationItem *)navItem {
    [super bindWithNavigationItem:navItem];
    
    NSString* title = NSLocalizedString(@"actions.cancel", nil);
    UIBarButtonItem* cancelItem = [UIBarButtonItem cancelItemWithTitle:title
                                                                 image:nil
                                                                target:self
                                                                action:@selector(cancel)];
    [navItem setLeftBarButtonItem:cancelItem];
}

- (void)bindWithNextButton:(UIButton*)nextButton {
    [super bindWithNextButton:nextButton];
    [nextButton setTitle:[NSLocalizedString(@"upgrade.new-sense.setup", nil) uppercaseString]
                forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(proceed) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithNeedButton:(UIButton*)needButton {
    [super bindWithNeedButton:needButton];
    [needButton setTitle:NSLocalizedString(@"upgrade.new-sense.learn-more", nil)
                forState:UIControlStateNormal];
    [needButton addTarget:self action:@selector(order) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindWithIllustrationView:(UIImageView *)illustrationView {
    [super bindWithIllustrationView:illustrationView];
    [illustrationView setImage:[UIImage imageNamed:@"sensePlacement"]];
    [illustrationView setContentMode:UIViewContentModeScaleAspectFit];
}

#pragma mark - Actions

- (void)cancel {
    [[self actionDelegate] shouldDismissFrom:self];
}

- (void)proceed {
    [[self actionDelegate] shouldProceedFrom:self];
}

- (void)order {
    NSString* orderURLString = NSLocalizedString(@"help.url.order-form", nil);
    [[self actionDelegate] shouldOpenPageTo:orderURLString from:self];
}

@end
