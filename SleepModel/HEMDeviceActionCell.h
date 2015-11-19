//
//  HEMDeviceActionCell.h
//  Sense
//
//  Created by Jimmy Lu on 11/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMDeviceActionCellHeight;

@interface HEMDeviceActionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;

- (void)setEnabled:(BOOL)enabled;
- (void)showActivity:(BOOL)show withText:(NSString*)text;

@end
