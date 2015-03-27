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
@property (nonatomic, strong) NSArray* sectionHeaders;
@end

@implementation HEMGraphSectionOverlayView

static NSInteger const HEMGraphSectionLineWidth = 1.f;
static CGFloat const HEMGraphSectionLabelHeight = 20.f;
static CGFloat const HEMGraphLabelInset = 5.f;
static CGFloat const HEMGraphLabelBottomOffset = 9.f;

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
    _showSeparatorLines = NO;
    _topLabelColor = [HelloStyleKit backViewTextColor];
    _bottomLabelColor = [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1];
    _topLabelFont = [UIFont sensorGraphHeadingFont];
    _topLabelBoldFont = [UIFont sensorGraphHeadingBoldFont];
    _bottomLabelFont = [UIFont sensorGraphNumberFont];
    _bottomLabelBoldFont = [UIFont sensorGraphNumberBoldFont];
}

- (void)setSectionFooters:(NSArray *)footers headers:(NSArray *)headers {
    self.sectionFooters = footers;
    self.sectionHeaders = headers;
    [self layoutSections];
}

- (void)layoutSections {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSInteger count = MAX(self.sectionFooters.count, self.sectionHeaders.count);
    if (count == 0)
        return;
    CGFloat sectionWidth = CGRectGetWidth(self.bounds)/count;
    CGFloat sectionHeight = CGRectGetHeight(self.bounds);
    CGFloat bottomLabelOffset = CGRectGetHeight(self.bounds) - HEMGraphLabelBottomOffset - HEMGraphSectionLabelHeight;
    NSArray* locations = @[@(0.2), @(0.75)];
    NSArray* colors = @[(id)[[[UIColor blackColor] colorWithAlphaComponent:0.05] CGColor],
                        (id)[[UIColor clearColor] CGColor]];
    for (int i = 0 ; i < count; i++) {
        CGFloat xOffset = i * sectionWidth;
        CGRect bottomLabelRect = CGRectInset(CGRectMake(xOffset, bottomLabelOffset, sectionWidth, HEMGraphSectionLabelHeight), HEMGraphLabelInset, 0);
        CGRect topLabelRect = CGRectInset(CGRectMake(xOffset, 0, sectionWidth, HEMGraphSectionLabelHeight), HEMGraphLabelInset, 0);
        UILabel* bottomLabel = [[UILabel alloc] initWithFrame:bottomLabelRect];
        UILabel* topLabel = [[UILabel alloc] initWithFrame:topLabelRect];
        if (self.sectionFooters.count > i)
            bottomLabel.text = self.sectionFooters[i];
        if (self.sectionHeaders.count > i)
            topLabel.text = self.sectionHeaders[i];
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.textAlignment = NSTextAlignmentCenter;
        BOOL isBold = [self shouldBoldLastElement] && (i == count - 1);
        if (isBold) {
            bottomLabel.font = self.bottomLabelBoldFont;
            bottomLabel.textColor = [UIColor blackColor];
            topLabel.font = self.topLabelBoldFont;
            topLabel.textColor = [UIColor blackColor];
        } else {
            bottomLabel.font = self.bottomLabelFont;
            bottomLabel.textColor = self.bottomLabelColor;
            topLabel.font = self.topLabelFont;
            topLabel.textColor = self.topLabelColor;
        }
        bottomLabel.minimumScaleFactor = 0.5;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        topLabel.minimumScaleFactor = 0.5;
        topLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:bottomLabel];
        [self addSubview:topLabel];
        if ([self shouldShowSeparatorLines]) {
            if (i > 0) {
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = CGRectMake(xOffset - HEMGraphSectionLineWidth, 0, HEMGraphSectionLineWidth, sectionHeight);
                gradient.colors = colors;
                gradient.locations = locations;
                [self.layer insertSublayer:gradient atIndex:0];
            }
        }
    }
}
@end
