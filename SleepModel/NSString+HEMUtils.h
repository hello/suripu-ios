//
//  NSString+HEMUtils.h
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

@interface NSString (HEMUtils)

/**
 * Simple convenience method to check whether or not this string
 * is a valid email address
 *
 * @return YES if valid email, NO otherwise
 */
- (BOOL)isValidEmail;

/**
 *  Remove trailing whitespace
 *
 *  @return string minus trailing whitespace
 */
- (NSString*)trim;

@end