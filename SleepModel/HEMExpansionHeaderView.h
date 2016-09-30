//
//  HEMExpansionHeaderView.h
//  Sense
//
//  Created by Jimmy Lu on 9/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMURLImageView;

@interface HEMExpansionHeaderView : UIView

@property (nonatomic, weak) IBOutlet HEMURLImageView* urlImageView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* subtitleLabel;
@property (nonatomic, weak) IBOutlet UILabel* descriptionLabel;

@end
