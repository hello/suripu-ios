//
//  HEMClockPickerView.h
//  Sense
//
//  Created by Delisa Mason on 2/9/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HEMClockPickerViewDelegate <NSObject>

@required

- (void)didUpdateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute;

@end

@interface HEMClockPickerView : UIView

- (void)updateTimeToHour:(NSUInteger)hour minute:(NSUInteger)minute;

@property (nonatomic, readonly) NSUInteger hour;
@property (nonatomic, readonly) NSUInteger minute;
@property (nonatomic, weak) id<HEMClockPickerViewDelegate> delegate;
@end
