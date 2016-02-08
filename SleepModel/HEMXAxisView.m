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

- (void)clear {
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addLabelWithText:(NSAttributedString*)text
                     atX:(CGFloat)xOrigin
           maxLabelWidth:(CGFloat)maxLabelWidth {
    [self addSubview:[self labelWithText:text
                               atXOrigin:xOrigin
                                maxWidth:maxLabelWidth]];
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
