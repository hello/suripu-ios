//
//  NSShadow+HEMStyle.m
//  Sense
//
//  Created by Jimmy Lu on 9/8/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "NSShadow+HEMStyle.h"

@implementation NSShadow (HEMStyle)

+ (NSShadow*)shadowStyleWithColor:(UIColor*)color
                           offset:(CGSize)offset
                           radius:(CGFloat)radius {
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:color];
    [shadow setShadowOffset:offset];
    [shadow setShadowBlurRadius:radius];
    return shadow;
}

+ (NSShadow*)shadowForHandholdingMessage {
    return [self shadowStyleWithColor:[UIColor colorWithWhite:0.0f alpha:0.3f]
                               offset:CGSizeZero
                               radius:5.0f];
}

@end
