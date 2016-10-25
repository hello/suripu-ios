//
//  HEMAlarmValueRangePickerView.h
//  Sense
//
//  Created by Jimmy Lu on 10/20/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMAlarmValueRangePickerView;

@protocol HEMAlarmValueRangePickerDelegate <NSObject>

- (void)didUpdateSelectedValuesFrom:(HEMAlarmValueRangePickerView*)pickerView;

@end

@interface HEMAlarmValueRangePickerView : UIView

@property (nonatomic, weak) IBOutlet UIView* topGradientView;
@property (nonatomic, weak) IBOutlet UIView* botGradientView;
@property (nonatomic, weak) IBOutlet UIView* separator;

@property (nonatomic, weak) id<HEMAlarmValueRangePickerDelegate> pickerDelegate;
@property (nonatomic, copy) NSString* unitSymbol;
@property (nonatomic, assign) NSInteger selectedMinValue;
@property (nonatomic, assign) NSInteger selectedMaxValue;

- (void)configureRangeWithMin:(NSInteger)min max:(NSInteger)max;
- (void)configureWithMin:(NSInteger)min max:(NSInteger)max;

@end
