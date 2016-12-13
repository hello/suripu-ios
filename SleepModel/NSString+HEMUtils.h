//
//  NSString+HEMUtils.h
//  Sense
//
//  Created by Delisa Mason on 12/16/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (HEMUtils)

/**
 * @discussion
 * parameter must be a single word
 *
 * @param word: word to camel case
 * @return word, camel cased
 */
+ (NSString*)camelCaseWord:(NSString*)word;

/**
 * Simple convenience method to check whether or not this string
 * is a valid email address
 *
 * @return YES if valid email, NO otherwise
 */
- (BOOL)isValidEmail;

/**
 *  Remove trailing whitespace
 *
 *  @return string minus trailing whitespace
 */
- (NSString*)trim;

/**
 * Calculate the necessary height to display the string given the width constraint
 * and the font used for the text
 * 
 * @param width: the width constraint
 * @param font: the font to be used for the text
 */
- (CGFloat)heightBoundedByWidth:(CGFloat)width usingFont:(UIFont*)font;

/**
 *  Calculate the necessary height to display a string given the attributes and
 *  width constraint
 *
 *  @param width      maximum width of a line of text
 *  @param attributes attributes of the text layout
 *
 *  @return the height of the string
 */
- (CGFloat)heightBoundedByWidth:(CGFloat)width attributes:(NSDictionary *)attributes;

/**
 *  Calculate the necessary height to display a string given the attributes,
 *  width constraint, as well as optional drawing options.
 *
 *  @param width      maximum width of a line of text
 *  @param attributes attributes of the text layout
 *  @param option     the drawing options used to calculate the size of the string
 *
 *  @return the height of the string
 */
- (CGFloat)heightBoundedByWidth:(CGFloat)width
                     attributes:(NSDictionary *)attributes
             withDrawingOptions:(NSStringDrawingOptions)option;

/**
 *  Calculate the neccessary size to display a string given the width constraint
 *  and attributes for the text
 *
 *  @param width      maximum width of a line of text
 *  @param attributes attributes of the text layout
 *
 *  @return the size of the string, bounded by width
 */
- (CGSize)sizeBoundedByWidth:(CGFloat)width attriburtes:(NSDictionary *)attributes;

/**
 *  Calculate the neccessary size to display a string given the height constraint
 *  and attributes for the text
 *
 *  @param height      maximum height of a line of text
 *  @param attributes attributes of the text layout
 *
 *  @return the size of the string, bounded by height
 */
- (CGSize)sizeBoundedByHeight:(CGFloat)height attributes:(NSDictionary *)attributes;

@end
