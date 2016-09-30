//
//  HEMBasicTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMURLImageView;

@interface HEMBasicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HEMURLImageView *remoteImageView;
@property (weak, nonatomic) IBOutlet UILabel* customDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel* customTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton* infoButton;
@property (weak, nonatomic) IBOutlet UIView* customAccessoryView;

- (void)showSeparator:(BOOL)show;

@end
