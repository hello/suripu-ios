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

@property (nonatomic, strong) NSMutableArray* sectionHeaders;
@property (nonatomic, strong) NSMutableArray* sectionFooters;
@end

@implementation HEMGraphSectionOverlayView

static NSInteger const HEMGraphSectionLineWidth = 1.f;
static CGFloat const HEMGraphSectionLabelHeight = 15.f;

- (void)setSectionValues:(NSArray *)sectionValues {
    self.sectionHeaders = [[NSMutableArray alloc] initWithCapacity:sectionValues.count];
    self.sectionFooters = [[NSMutableArray alloc] initWithCapacity:sectionValues.count];
    for (NSDictionary* dict in sectionValues) {
        [self.sectionHeaders addObject:[[dict allKeys] firstObject]];
        [self.sectionFooters addObject:[[dict allValues] firstObject]];
    }
    [self layoutSections];
}

- (void)layoutSections {
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSInteger count = self.sectionHeaders.count;
    CGFloat sectionWidth = (CGRectGetWidth(self.bounds)/(count - 1)) - (count * HEMGraphSectionLineWidth);
    CGFloat sectionHeight = CGRectGetHeight(self.bounds) * 0.9;
    CGFloat bottomLabelOffset = CGRectGetHeight(self.bounds) * 0.8;
    CGFloat yOffset = 0.f;
    NSArray* locations = @[@(0.2), @1];
    NSArray* colors = @[
                        (id)[[UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1] CGColor],
                        (id)[[UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:0.2] CGColor]];
    for (int i = 0 ; i < count; i++) {
        CGFloat xOffset = (i * sectionWidth) + (i * HEMGraphSectionLineWidth);
        UILabel* topLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, sectionWidth, HEMGraphSectionLabelHeight)];
        UILabel* bottomLabel = [[UILabel alloc] initWithFrame:CGRectInset(CGRectMake(xOffset, bottomLabelOffset, sectionWidth, HEMGraphSectionLabelHeight), 5.f, 0)];
        topLabel.text = self.sectionHeaders[i];
        bottomLabel.text = self.sectionFooters[i];
        topLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        BOOL isBold = (i == count - 1);
        topLabel.font = isBold ? [UIFont sensorGraphHeadingBoldFont] : [UIFont sensorGraphHeadingFont];
        bottomLabel.font = isBold ? [UIFont sensorGraphNumberBoldFont] : [UIFont sensorGraphNumberFont];
        topLabel.textColor = [HelloStyleKit backViewTextColor];
        bottomLabel.textColor = [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1];
        bottomLabel.minimumScaleFactor = 0.5;
        bottomLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:topLabel];
        [self addSubview:bottomLabel];
        if (i > 0) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = CGRectMake(xOffset, yOffset,
                                        HEMGraphSectionLineWidth, sectionHeight);
            gradient.colors = colors;
            gradient.locations = locations;
            [self.layer insertSublayer:gradient atIndex:0];
        }
    }
}
@end
