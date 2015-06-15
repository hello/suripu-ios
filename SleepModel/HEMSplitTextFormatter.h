//
//  HEMSplitTextFormatter.h
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEMSplitTextObject : NSObject
- (instancetype)initWithValue:(NSString*)value
                         unit:(NSString*)unit;
@end

@interface HEMSplitTextFormatter : NSFormatter

@end
