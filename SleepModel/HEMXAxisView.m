//
//  HEMXAxisView.m
//  Sense
//
//  Created by Jimmy Lu on 2/4/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMXAxisView.h"

@interface HEMXAxisView()

@end

@implementation HEMXAxisView

- (void)showLabelsFromX:(CGFloat)start
  withAttributedStrings:(NSArray<NSAttributedString*>*)strings
           labelSpacing:(CGFloat)labelSpacing
          maxLabelWidth:(CGFloat)maxLabelWidth {
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat xOrigin = start;
    for (NSAttributedString* string in strings) {
        UILabel* xLabel = [self labelWithText:string atXOrigin:xOrigin maxWidth:maxLabelWidth];
        [self addSubview:xLabel];
        xOrigin = CGRectGetMaxX([xLabel frame]) + labelSpacing;
    }
}

- (UILabel*)labelWithText:(NSAttributedString*)text
                atXOrigin:(CGFloat)xOrigin
                 maxWidth:(CGFloat)maxWidth {
    CGFloat maxHeight = CGRectGetHeight([self bounds]);
    
    UILabel* label = [UILabel new];
    [label setAttributedText:text];
    
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = xOrigin;
    labelFrame.size.height = maxHeight;
    
    if (maxWidth != MAXFLOAT) {
        labelFrame.size.width = maxWidth;
    } else {
        CGSize constraint = CGSizeMake(maxWidth, maxHeight);
        CGSize textSize = [label sizeThatFits:constraint];
        labelFrame.size.width = ceilCGFloat(textSize.width);
    }
    
    [label setFrame:labelFrame];
    
    return label;
}

@end
