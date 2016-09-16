//
//  HEMSensorScaleView.h
//  Sense
//
//  Created by Jimmy Lu on 9/15/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kHEMSensorScaleHeight;

@interface HEMSensorScaleView : UIView

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* rangeLabel;
@property (weak, nonatomic) IBOutlet UIView* conditionView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

+ (instancetype)scaleView;

@end
