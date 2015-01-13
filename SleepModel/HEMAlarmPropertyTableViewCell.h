//
//  HEMAlarmPropertyTableViewCell.h
//  Sense
//
//  Created by Delisa Mason on 1/12/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTSpinKitView;

@interface HEMAlarmPropertyTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView* disclosureImageView;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet RTSpinKitView* loadingIndicatorView;
@end
