//
//  HEMNoDeviceCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 1/7/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import "HEMNoDeviceCollectionViewCell.h"
#import "HelloStyleKit.h"
#import "HEMActionButton.h"
#import "UIColor+HEMStyle.h"

@implementation HEMNoDeviceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self actionButton] setUserInteractionEnabled:NO]; // let cell cause the action instead
}

- (void)configureForSense {
    self.iconImageView.image = [HelloStyleKit senseIcon];
    self.nameLabel.text = NSLocalizedString(@"settings.device.sense", nil);
    self.messageLabel.text = NSLocalizedString(@"settings.device.no-sense", nil);
    [self.actionButton setTitle:NSLocalizedString(@"settings.device.button.title.pair-sense", nil)
                       forState:UIControlStateNormal];
    [[self actionButton] setBackgroundColor:[UIColor tintColor]];
    [[self actionButton] setHidden:NO];
    [self setUserInteractionEnabled:YES];
}

- (void)configureForPill:(BOOL)canPair {
    self.iconImageView.image = [HelloStyleKit pillIcon];
    self.nameLabel.text = NSLocalizedString(@"settings.device.pill", nil);
    self.messageLabel.text = NSLocalizedString(@"settings.device.no-pill", nil);
    [self.actionButton setTitle:NSLocalizedString(@"settings.device.button.title.pair-pill", nil)
                       forState:UIControlStateNormal];
    [[self actionButton] setHidden:!canPair];
    [self setUserInteractionEnabled:canPair];
}

@end
