//
//  HEMActionSheetOptionCell.h
//  Sense
//
//  Created by Jimmy Lu on 4/22/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMActionSheetOptionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidth;

+ (CGFloat)heightWithTitle:(NSString *)title description:(NSString *)description maxWidth:(CGFloat)width;

- (void)setDescription:(NSString *)description;

@end
