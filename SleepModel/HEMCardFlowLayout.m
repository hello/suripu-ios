//
//  HEMCardFlowLayout.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardFlowLayout.h"
#import "HEMScreenUtils.h"

@interface HEMCardFlowLayout ()

@property (nonatomic, assign) CGFloat latestDelta;
@end

@implementation HEMCardFlowLayout

static CGFloat const HEMCardSectionMargin = 16.f;
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
    self.itemSize = CGSizeMake(CGRectGetWidth(bounds) - HEMCardCardMargin * 2, HEMCardDefaultItemHeight);
    self.sectionInset = UIEdgeInsetsMake(HEMCardSectionMargin, 0, HEMCardSectionMargin, 0);
    self.minimumInteritemSpacing = HEMCardCardMargin;
    self.minimumLineSpacing = HEMCardCardMargin;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
}

/**
 * @override 
 * layoutAttributesForElementsInRect:
 *
 * @discussion
 * If attributes are returned for an indexpath that is invalid, app will crash in
 * iOS 8.  Seems like an iOS bug?
 *
 * TODO: see if there's a better way to handle this unless it is an iOS bug since
 * the OS should really be the one handling this
 */
- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    NSMutableArray* updatedAttributes = [NSMutableArray arrayWithCapacity:[attributes count]];
    NSInteger numberOfSections = [[self collectionView] numberOfSections];
    
    for (UICollectionViewLayoutAttributes* attribute in attributes) {
        NSInteger section = [[attribute indexPath] section];
        if (section < numberOfSections) {
            NSInteger item = [[attribute indexPath] item];
            NSInteger numberOfItems = [[self collectionView] numberOfItemsInSection:section];
            if (item < numberOfItems) {
                [updatedAttributes addObject:attribute];
            }
        }
    }
    
    return updatedAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
