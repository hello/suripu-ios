//
//  HEMValueSliderView.h
//  Sense
//
//  Created by Jimmy Lu on 8/21/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMValueSliderView;

@protocol HEMValueSliderDelegate <NSObject>

- (NSInteger)numberOfRowsInSliderView:(HEMValueSliderView*)sliderView;
- (NSNumber*)sliderView:(HEMValueSliderView*)sliderView numberForRow:(NSInteger)row;
- (float)incrementalValuePerRowInSliderView:(HEMValueSliderView*)sliderView;

@optional
- (void)sliderView:(HEMValueSliderView*)sliderView didScrollToValue:(float)value;

@end

@interface HEMValueSliderView : UIView

@property (nonatomic, weak) IBOutlet id<HEMValueSliderDelegate> delegate;

- (void)reload;
- (void)setToInches:(float)inches;

@end
