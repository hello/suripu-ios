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

- (void)showSeparator:(BOOL)show;

@end
