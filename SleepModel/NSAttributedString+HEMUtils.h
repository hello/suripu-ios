//
//  NSAttributedString+HEMUtils.h
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (HEMUtils)

- (NSAttributedString *)trim;
- (NSAttributedString *)hyperlink:(NSString*)url;
- (NSAttributedString*)hyperlink:(NSString *)url font:(UIFont*)font;
- (NSAttributedString*)hyperlink:(NSString *)url font:(UIFont*)font color:(UIColor*)color;
- (CGSize)sizeWithWidth:(CGFloat)width;
- (CGSize)sizeWithHeight:(CGFloat)height;

@end
