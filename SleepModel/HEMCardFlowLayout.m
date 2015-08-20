//
//  HEMCardFlowLayout.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardFlowLayout.h"

@interface HEMCardFlowLayout ()

@property (nonatomic, assign) CGFloat latestDelta;
@end

@implementation HEMCardFlowLayout

static CGFloat const HEMCardOutsideMargin = 16.f;
static CGFloat const HEMCardInsideMargin = 16.f;
static CGFloat const HEMCardDefaultItemHeight = 100.f;

- (instancetype)init {
    if (self = [super init]) {
        [self configureDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureDefaultAttributes];
    }
    return self;
}

- (void)configureDefaultAttributes {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.itemSize = CGSizeMake(CGRectGetWidth(bounds) - HEMCardOutsideMargin * 2, HEMCardDefaultItemHeight);
    self.sectionInset = UIEdgeInsetsMake(HEMCardOutsideMargin, 0, HEMCardOutsideMargin, 0);
    self.minimumInteritemSpacing = HEMCardInsideMargin;
    self.minimumLineSpacing = HEMCardInsideMargin;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
