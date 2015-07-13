//
//  UIImage+HEMBlurTint.h
//  Sense
//
//  Created by Delisa Mason on 7/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HEMBlurTint)

- (UIImage*)imageWithTint:(UIColor*)color;
- (UIImage*)blurredImageWithTint:(UIColor*)color;
@end
