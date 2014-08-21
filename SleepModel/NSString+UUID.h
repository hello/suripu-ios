//
//  NSString+UUID.h
//  Sense
//
//  Created by Jimmy Lu on 8/20/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UUID)

//
// Generate a universally unique identifier
//
// @return uuid generated
//
+ (NSString*)uuid;

@end
