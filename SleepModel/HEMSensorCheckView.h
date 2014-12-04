//
//  HEMSensorCheckView.h
//  Sense
//
//  Created by Jimmy Lu on 12/3/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEMSensorCheckCollapsedHeight;

@interface HEMSensorCheckView : UIView

- (instancetype)initWithIcon:(UIImage*)icon
             highlightedIcon:(UIImage*)highlighedIcon
                       title:(NSString*)title
                     message:(NSString*)message;

@end
