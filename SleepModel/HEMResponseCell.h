//
//  HEMResponseCell.h
//  Sense
//
//  Created by Jimmy Lu on 12/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMResponseCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* answerLabel;
@property (nonatomic, weak) IBOutlet UIView* separator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end
