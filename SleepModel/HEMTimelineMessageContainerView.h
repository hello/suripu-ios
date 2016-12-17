//
//  HEMTimelineMessageContainerView.h
//  Sense
//
//  Created by Delisa Mason on 6/12/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMTappableView.h"

@interface HEMTimelineMessageContainerView : HEMTappableView

@property (weak, nonatomic) IBOutlet UILabel* messageLabel;
@property (weak, nonatomic) IBOutlet UILabel* summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView* chevron;

@end
