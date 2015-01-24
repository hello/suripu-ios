//
//  NSMutableAttributedString+HEMFormat.h
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (HEMFormat)

/**
 * Initialize an instance with the specified format, appending the arg in place
 * of the placeholder.  The only supported format symbol is %@ since each arg
 * in the array must be an instance of NSAttributedString.  If any arg is not
 * of such instance, it will be ignored.  If the number of symbols in the format
 * does not match the number of arguments, it will be ignored.
 *
 * @param format: format with %@ as placeholders
 * @param args:   an array of NSAttributedString
 */
- (instancetype)initWithFormat:(NSString*)format args:(NSArray*)args;

/**
 * Initialize an instance with the specified format, appending the arg in place
 * of the placeholder.  The only supported format symbol is %@ since each arg
 * in the array must be an instance of NSAttributedString.  If any arg is not
 * of such instance, it will be ignored.  If the number of symbols in the format
 * does not match the number of arguments, it will be ignored.
 *
 * @param format: format with %@ as placeholders
 * @param args:   an array of NSAttributedString
 * @param color:  the color to use for the text, if color has not yet been applied
 * @param font:   the font to use for the text, if font has not yet been applied
 */
- (instancetype)initWithFormat:(NSString *)format
                          args:(NSArray *)args
                     baseColor:(UIColor*)color
                      baseFont:(UIFont*)font;

@end
