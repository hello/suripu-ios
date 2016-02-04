//
//  HEMTrendsSleepDepthView.h
//  Sense
//
//  Created by Jimmy Lu on 2/3/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTrendsSleepDepthView : UIView

- (void)setLightPercentage:(CGFloat)lightPercentage
            localizedTitle:(NSString*)localizedTitle;

- (void)setMediumPercentage:(CGFloat)mediumPercentage
             localizedTitle:(NSString*)localizedTitle;

- (void)setDeepPercentage:(CGFloat)deepPercentage
           localizedTitle:(NSString*)localizedTitle;

- (void)render;

@end
