//
//  HEMListItemCell.h
//  Sense
//
//  Created by Jimmy Lu on 3/25/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMListItemCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UIImageView* selectionImageView;
@property (weak, nonatomic, nullable) IBOutlet UILabel* itemLabel;
@property (weak, nonatomic, nullable) IBOutlet UILabel *descriptionLabel;
    
- (void)enable:(BOOL)enable;

@end
