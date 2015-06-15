//
//  HEMSplitTextFormatter.m
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMSplitTextFormatter.h"

@interface HEMSplitTextFormatter ()
@property (nonatomic, strong) NSLocale *locale;
@end

@interface HEMSplitTextObject ()
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *unit;
@end

@implementation HEMSplitTextObject

CGFloat const smallTextRatio = 0.67f;

- (instancetype)initWithValue:(NSString *)value unit:(NSString *)unit {
    if (self = [super init]) {
        _value = value;
        _unit = unit;
    }
    return self;
}

@end

@implementation HEMSplitTextFormatter

- (instancetype)init {
    if (self = [super init]) {
        _locale = [NSLocale currentLocale];
    }
    return self;
}

- (NSAttributedString *)attributedStringForObjectValue:(HEMSplitTextObject *)splitText
                                 withDefaultAttributes:(NSDictionary *)attrs {
    if (![splitText isKindOfClass:[HEMSplitTextObject class]]) {
        return nil;
    }
    NSMutableAttributedString *result =
        [[NSMutableAttributedString alloc] initWithString:splitText.value attributes:attrs];
    NSString *languageCode = [self.locale objectForKey:NSLocaleLanguageCode];
    if ([languageCode isEqualToString:@"en"] && splitText.unit.length > 0) {
        NSMutableDictionary *unitAttrs = [attrs mutableCopy];
        UIFont *selectedFont = attrs[NSFontAttributeName];
        NSString* unitText = [NSString stringWithFormat:@" %@", splitText.unit];
        if (selectedFont) {
            CGFloat pointSize = ceilf(selectedFont.pointSize * smallTextRatio);
            unitAttrs[NSFontAttributeName] = [selectedFont fontWithSize:pointSize];
        }
        NSAttributedString *unitString =
            [[NSAttributedString alloc] initWithString:unitText attributes:unitAttrs];
        [result appendAttributedString:unitString];
    } else if (splitText.unit.length > 0) {
        NSAttributedString *unitString = [[NSAttributedString alloc] initWithString:splitText.unit attributes:attrs];
        [result appendAttributedString:unitString];
    }
    return result;
}
@end
