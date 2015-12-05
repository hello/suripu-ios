//
//  NSShadow+HEMStyle.h
//  Sense
//
//  Created by Jimmy Lu on 9/8/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSShadow (HEMStyle)

/**
 * @return shadow for the message container of a handholding tutorial
 */
+ (NSShadow*)shadowForHandholdingMessage;

/**
 * @return shadow to show when content is beyond the view port
 */
+ (NSShadow*)contentShadow;

@end
