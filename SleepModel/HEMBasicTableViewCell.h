//
//  HEMBasicTableViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 5/17/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMURLImageView;
@class HEMActivityIndicatorView;

@interface HEMBasicTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HEMURLImageView *remoteImageView;
@property (weak, nonatomic) IBOutlet UILabel* customDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel* customTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton* infoButton;
@property (weak, nonatomic) IBOutlet UIView* customAccessoryView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView* activityView;

@property (assign, nonatomic, getter=isLoading) BOOL loading;

- (void)showSeparator:(BOOL)show;

/**
 * @discussion
 * Requires activityView to be set.  If set, activity will be shown while
 * customAccessoryView, accessoryView, and custom detail labels will be hidden.
 * If specified to not show, the mentioned views will be shown again.
 */
- (void)showActivity:(BOOL)show;

- (void)showCustomAccessoryView:(BOOL)show;

@end
