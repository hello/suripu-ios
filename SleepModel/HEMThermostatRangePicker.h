//
//  HEMThermostatRangePicker.h
//  Sense
//
//  Created by Jimmy Lu on 11/6/16.
//  Copyright � 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICountingLabel;

@interface HEMThermostatRangePicker : UIView

@property (weak, nonatomic) IBOutlet UICountingLabel* minLabel;
@property (weak, nonatomic) IBOutlet UICountingLabel* maxLabel;

@property (weak, nonatomic) IBOutlet UILabel* separatorLabel;

@property (weak, nonatomic) IBOutlet UIButton* increaseMinButton;
@property (weak, nonatomic) IBOutlet UIButton* decreaseMinButton;
@property (weak, nonatomic) IBOutlet UIButton* increaseMaxButton;
@property (weak, nonatomic) IBOutlet UIButton* decreaseMaxButton;

@property (assign, nonatomic) CGFloat minLimit; // defaults to 0
@property (assign, nonatomic) CGFloat maxLimit; // defaults to 100

+ (instancetype)rangePickerWithMin:(NSInteger)min
                               max:(NSInteger)max
                      withMinLimit:(CGFloat)minLimit
                          maxLimit:(CGFloat)maxLimit;

@end
