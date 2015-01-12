//
//  HEMGraphSectionOverlayView.m
//  Sense
//
//  Created by Delisa Mason on 11/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMGraphSectionOverlayView.h"
#import "HelloStyleKit.h"
#import "UIFont+HEMStyle.h"

@interface HEMGraphSectionOverlayView ()

@property (nonatomic, strong) NSArray* sectionFooters;
@end

@implementation HEMGraphSectionOverlayView

static NSInteger const HEMGraphSectionLineWidth = 1.f;
static CGFloat const HEMGraphSectionLabelHeight = 15.f;

- (instancetype)init {
    if (self = [super init]) {
        [self __initializeLayout];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __initializeLayout];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __initializeLayout];
    }
    return self;
}

- (void)__initializeLayout {
    _boldLastElement = YES;
    _topLabelColor = [HelloStyleKit backViewTextColor];
    _bottomLabelColor = [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1];
    _topLabelFont = [UIFont sensorGraphHeadingFont];
    _topLabelBoldFont = [UIFont sensorGraphHeadingBoldFont];
    _bottomLabelFont = [UIFont sensorGraphNumberFont];
    _bottomLabelBoldFont = [UIFont sensorGraphNumberBoldFont];
}

- (void)setSectionValues:(NSArray *)sectionValues {
    self.sectionFooters = sectionValues;
    [self layoutSections];
}

- (void)layoutSections {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSInteger count = self.sectionFooters.count;
    CGFloat sectionWidth = floorf(CGRectGetWidth(self.bounds)/count);
    CGFloat bottomLabelOffset = CGRectGetHeight(self.bounds) * 0.8;
    for (int i = 0 ; i < count; i++) {
        CGFloat xOffset = (i * sectionWidth) + (i * HEMGraphSectionLineWidth);
        CGRect bottomLabelRect = CGRectInset(CGRectMake(xOffset, bottomLabelOffset, sectionWidth, HEMGraphSectionLabelHeight), 5.f, 0);
        UILabel* bottomLabel = [[UILabel alloc] initWithFrame:bottomLabelRect];
        bottomLabel.text = self.sectionFooters[i];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        BOOL isBold = [self shouldBoldLastElement] && (i == count - 1);
        if (isBold) {
            bottomLabel.font = self.bottomLabelBoldFont;
            bottomLabel.textColor = [UIColor blackColor];
        } else {
            bottomLabel.font = self.bottomLabelFont;
            bottomLabel.textColor = self.bottomLabelColor;
        }
        bottomLabel.minimumScaleFactor = 0.5;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:bottomLabel];
    }
}
@end
