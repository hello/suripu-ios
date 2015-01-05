//
//  HEMSystemAlertController.h
//  Sense
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSystemAlertController : NSObject

- (instancetype)initWithViewController:(UIViewController*)viewController;

- (void)enableDeviceMonitoring:(BOOL)enable;

@end
