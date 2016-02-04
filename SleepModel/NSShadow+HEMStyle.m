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

+ (NSShadow*)shadowForActionView {
    return [self shadowStyleWithColor:[UIColor colorWithWhite:0.0f alpha:0.1f]
                               offset:CGSizeMake(0.1f, -2.1f)
                               radius:5.0f];
}

+ (NSShadow*)shadowForBackViewCards {
    return [self shadowStyleWithColor:[UIColor colorWithWhite:0.0f alpha:0.02f]
                               offset:CGSizeMake(0.1f, 1.6f)
                               radius:0.0f];
}

+ (NSShadow*)shadowForButtonContainer {
    return [self shadowStyleWithColor:[UIColor colorWithWhite:0.0f alpha:0.1f]
                               offset:CGSizeMake(0.1f, 1.1f)
                               radius:3.0f];
}

+ (NSShadow*)shadowForTrendsSleepDepthCircles {
    return [self shadowStyleWithColor:[UIColor colorWithWhite:0.0f alpha:0.1f]
                               offset:CGSizeMake(0, 2.0f)
                               radius:2.0f];
}

@end
