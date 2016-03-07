//
//  HEMTrendsCircleView.h
//  Sense
//
//  Created by Jimmy Lu on 2/2/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTrendsCircleView : UIView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)color;
- (void)setAttributedValue:(NSAttributedString*)attributedValue
                     title:(NSAttributedString*)attributedTitle;

@end
