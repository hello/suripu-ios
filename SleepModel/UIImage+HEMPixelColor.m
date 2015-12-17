//
//  UIImage+HEMPixelColor.m
//  Sense
//
//  Created by Jimmy Lu on 12/8/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UIImage+HEMPixelColor.h"

@implementation UIImage (HEMPixelColor)

- (UIColor*)colorAtPosition:(CGPoint)position {
    
    CGRect sourceRect = CGRectMake(position.x, position.y, 1.f, 1.f);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], sourceRect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *buffer = malloc(4);
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(buffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, 1.0f, 1.0f), imageRef);
    CGImageRelease(imageRef);
    CGContextRelease(context);
    
    CGFloat r = buffer[0] / 255.0f;
    CGFloat g = buffer[1] / 255.0f;
    CGFloat b = buffer[2] / 255.0f;
    CGFloat a = buffer[3] / 255.0f;
    
    free(buffer);
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
