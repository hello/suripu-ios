//
//  NSMutableAttributedString+HEMFormat.m
//  Sense
//
//  Created by Jimmy Lu on 10/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "Sense-Swift.h"
#import "NSMutableAttributedString+HEMFormat.h"

static NSString* const kHEMStringFormatSymbol = @"%@";

@implementation NSMutableAttributedString (HEMFormat)

- (instancetype)initWithFormat:(NSString*)format args:(NSArray*)args {
    if (self = [self init]) {
        [self process:format args:args];
        
        UIColor* baseColor = [SenseStyle colorWithGroup:GroupAttributedString property:ThemePropertyTextColor];
        UIFont* baseFont = [SenseStyle fontWithGroup:GroupAttributedString property:ThemePropertyTextFont];
        [self applyColor:baseColor andFont:baseFont];
    }
    return self;
}

- (instancetype)initWithFormat:(NSString *)format
                          args:(NSArray *)args
                     baseColor:(UIColor*)color
                      baseFont:(UIFont*)font {
    if (self = [self init]) {
        [self process:format args:args];
        [self applyColor:color andFont:font];
    }
    return self;
}

- (instancetype)initWithFormat:(NSString *)format
                          args:(NSArray *)args
                    attributes:(NSDictionary*)attributes {
    if (self = [self init]) {
        [self process:format args:args];
        [self applyAttributes:attributes];
    }
    return self;
}

- (void)process:(NSString*)format args:(NSArray*)args {
    NSScanner* scanner = [NSScanner scannerWithString:format];
    [scanner setCharactersToBeSkipped:nil]; // otherwise, whitespace will be skipped
    
    NSString* scanned = nil;
    NSUInteger argIndex = 0;
    NSMutableAttributedString* attrArg = nil;
    NSInteger argCount = [args count];
    
    while (![scanner isAtEnd]) {
        [scanner scanUpToString:kHEMStringFormatSymbol intoString:&scanned];
        
        if (scanned) {
            [self appendAttributedString:[[NSAttributedString alloc] initWithString:scanned]];
        }
        
        if ([scanner scanString:kHEMStringFormatSymbol intoString:NULL]) {
            if (argIndex < argCount) {
                attrArg = args[argIndex];
                if ([attrArg isKindOfClass:[NSAttributedString class]]) {
                    [self appendAttributedString:attrArg];
                }
            }
            argIndex++;
        }
    }
    
}

- (void)applyAttributes:(NSDictionary*)attributes {
    NSArray* allKeys = [attributes allKeys];
    [self enumerateAttributesInRange:NSMakeRange(0, [self length])
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:^(NSDictionary *currentAttributes, NSRange range, BOOL *stop) {
                              for (NSString* key in allKeys) {
                                  if ([key isEqualToString:NSFontAttributeName]
                                      && [currentAttributes valueForKey:key] != nil
                                      && [attributes valueForKey:key] != nil) {
                                      
                                      UIFont* currentFont = [currentAttributes valueForKey:key];
                                      UIFont* font = [attributes valueForKey:key];
                                      if (![[currentFont familyName] isEqualToString:[font familyName]]) {
                                          [self addAttribute:key value:font range:range];
                                      }
                                  } else if ([currentAttributes valueForKey:key] == nil
                                      && [attributes valueForKey:key] != nil) {
                                      [self addAttribute:key value:[attributes valueForKey:key] range:range];
                                  }
                              }
                          }];
}

- (void)applyColor:(UIColor*)color andFont:(UIFont*)font {
    if (!color && !font) {
        return;
    }
    
    if ([self length] == 0) {
        return;
    }
    
    [self enumerateAttributesInRange:NSMakeRange(0, [self length])
                             options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                              if ([attrs valueForKey:NSFontAttributeName] == nil
                                  && font) {
                                  [self addAttribute:NSFontAttributeName
                                               value:font
                                               range:range];
                              }
                                  
                              if ([attrs valueForKey:NSForegroundColorAttributeName] == nil
                                  && color) {
                                  [self addAttribute:NSForegroundColorAttributeName
                                               value:color
                                               range:range];
                              }
                                  
                          }];
}

@end
