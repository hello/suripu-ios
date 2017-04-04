//
//  HEMCardFlowLayout.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMCardFlowLayout.h"
#import "HEMScreenUtils.h"

@interface HEMCardFlowLayout ()

@property (nonatomic, assign) CGFloat latestDelta;
@end

@implementation HEMCardFlowLayout

static CGFloat const HEMCardCardMargin = 8.f;
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
    CGRect bounds = HEMKeyWindowBounds();
    CGFloat topMargin = [SenseStyle floatWithGroup:GroupMargins property:ThemePropertyMarginTop];
    self.itemSize = CGSizeMake(CGRectGetWidth(bounds) - HEMCardCardMargin * 2, HEMCardDefaultItemHeight);
    self.sectionInset = UIEdgeInsetsMake(topMargin, 0, topMargin, 0);
    self.minimumInteritemSpacing = HEMCardCardMargin;
    self.minimumLineSpacing = HEMCardCardMargin;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

@end
