//
//  NSString+Email.h
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Email)

//
// Simple convenience method to check whether or not this string
// is a valid email address
//
// @return YES if valid email, NO otherwise
//
- (BOOL)isValidEmail;

@end
