//
//  HEMLogUtils.h
//  Sense
//
//  Created by Delisa Mason on 10/22/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMLogUtils : NSObject

+ (void)enableLogger;
+ (NSData*)latestLogFileData;
@end
