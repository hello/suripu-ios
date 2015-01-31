//
//  HEMAlarmPropertyTableViewCell.m
//  Sense
//
//  Created by Delisa Mason on 1/12/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <SpinKit/RTSpinKitView.h>
#import "HEMAlarmPropertyTableViewCell.h"
#import "HelloStyleKit.h"

@implementation HEMAlarmPropertyTableViewCell

- (void)awakeFromNib
{
    self.disclosureImageView.hidden = YES;
    self.loadingIndicatorView.hidesWhenStopped = YES;
    self.loadingIndicatorView.color = [HelloStyleKit tintColor];
    self.loadingIndicatorView.spinnerSize = CGRectGetHeight(self.loadingIndicatorView.bounds);
    self.loadingIndicatorView.style = RTSpinKitViewStyleArc;
    self.loadingIndicatorView.hidesWhenStopped = YES;
    self.loadingIndicatorView.backgroundColor = [UIColor clearColor];
    self.playStopButton.hidden = YES;
    [self.loadingIndicatorView stopAnimating];
}

@end
