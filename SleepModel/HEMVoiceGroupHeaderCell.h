//
//  HEMVoiceGroupHeaderCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMVoiceGroupHeaderCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView* imageView;
@property (nonatomic, weak) IBOutlet UILabel* categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel* messageLabel;

+ (CGFloat)heightWithCategory:(NSString*)category
                 categoryFont:(UIFont*)categoryFont
                      message:(NSString*)message
                  messageFont:(UIFont*)messageFont
                    fullWidth:(CGFloat)width;

@end
