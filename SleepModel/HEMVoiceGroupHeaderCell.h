//
//  HEMVoiceGroupHeaderCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMURLImageView;

@interface HEMVoiceGroupHeaderCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet HEMURLImageView* imageView;
@property (nonatomic, weak) IBOutlet UILabel* categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel* messageLabel;

+ (CGFloat)heightWithCategory:(NSString*)category message:(NSString*)message fullWidth:(CGFloat)width;
- (void)applyStyle;

@end
