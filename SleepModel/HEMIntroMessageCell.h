//
//  HEMTrendsMessageCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/11/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

@interface HEMIntroMessageCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

+ (CGFloat)heightWithTitle:(NSAttributedString*)title
                   message:(NSAttributedString*)message
                 withWidth:(CGFloat)width;

@end
