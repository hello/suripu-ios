//
//  HEMSensorValueCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HEMSensorValueCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *valueReplacementImageView;

- (void)replaceValueWithImage:(nullable UIImage*)image;

@end

NS_ASSUME_NONNULL_END