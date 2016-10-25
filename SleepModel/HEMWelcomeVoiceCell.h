//
//  HEMWelcomeVoiceCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@interface HEMWelcomeVoiceCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

+ (CGFloat)heightWithMessage:(NSString*)message
                    withFont:(UIFont*)font
                   cellWidth:(CGFloat)cellWidth;

@end
