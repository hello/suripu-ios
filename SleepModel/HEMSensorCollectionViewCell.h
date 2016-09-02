//
//  HEMSensorCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 9/1/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

@interface HEMSensorCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

+ (CGFloat)heightWithDescription:(NSString*)description
                       cellWidth:(CGFloat)cellWidth;

@end
