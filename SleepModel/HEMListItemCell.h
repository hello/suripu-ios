//
//  HEMListItemCell.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMListItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* selectionImageView;
@property (weak, nonatomic) IBOutlet UILabel* itemLabel;

- (void)flashTouchIndicator;

@end
