//
//  NSBundle+HEMUtils.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "NSBundle+HEMUtils.h"

@implementation NSBundle (HEMUtils)

+ (id)loadNibWithOwner:(id)owner {
    NSString* nibName = NSStringFromClass([owner class]);
    NSArray* contents = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    return [contents firstObject];
}

+ (NSString*)appVersionShort {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

@end
