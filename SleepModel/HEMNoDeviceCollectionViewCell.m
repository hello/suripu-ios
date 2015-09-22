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
    [[self actionButton] setUserInteractionEnabled:NO]; // let entire cell be tappable
    [[self actionButton] setBackgroundColor:[UIColor tintColor]];
}

- (void)configureForSense {
    self.iconImageView.image = [HelloStyleKit senseIcon];
    self.nameLabel.text = NSLocalizedString(@"settings.device.sense", nil);
    self.messageLabel.text = NSLocalizedString(@"settings.device.no-sense", nil);
    [self.actionButton setTitle:NSLocalizedString(@"settings.device.button.title.pair-sense", nil)
                       forState:UIControlStateNormal];
}

- (void)configureForPill:(BOOL)canPair {
    self.iconImageView.image = [HelloStyleKit pillIcon];
    self.nameLabel.text = NSLocalizedString(@"settings.device.pill", nil);
    self.messageLabel.text = NSLocalizedString(@"settings.device.no-pill", nil);
    [self.actionButton setTitle:NSLocalizedString(@"settings.device.button.title.pair-pill", nil)
                       forState:UIControlStateNormal];
    
    if (canPair) {
        [[self actionButton] setBackgroundColor:[UIColor tintColor]];
    } else {
        [[self actionButton] setBackgroundColor:[UIColor actionButtonDisabledColor]];
    }
    
    [self setUserInteractionEnabled:canPair];
}

@end
