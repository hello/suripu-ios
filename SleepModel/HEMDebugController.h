//
//  HEMDebugController.h
//  Sense
//
//  Created by Jimmy Lu on 12/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMDebugController : NSObject

+ (void)disableDebugMenuIfNeeded;
+ (BOOL)isEnabled;
- (id)initWithViewController:(UIViewController*)controller;
- (void)showSupportOptions;

@end
