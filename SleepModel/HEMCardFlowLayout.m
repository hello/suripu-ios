//
//  HEMCardFlowLayout.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardFlowLayout.h"

@interface HEMCardFlowLayout ()

@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;
@end

@implementation HEMCardFlowLayout

static CGFloat const HEMCardOutsideMargin = 16.f;
static CGFloat const HEMCardInsideMargin = 8.f;
static CGFloat const HEMCardDefaultItemHeight = 100.f;
static CGFloat const HEMCardAttachmentLength = 1.f;
static CGFloat const HEMCardAttachmentDamping = 0.8f;
static CGFloat const HEMCardAttachmentFrequency = 0.8f;
static CGFloat const HEMCardResistanceCoefficient = 1350.f;

- (instancetype)init
{
    if (self = [super init]) {
        [self configureDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configureDefaultAttributes];
    }
    return self;
}

- (void)configureDefaultAttributes
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.itemSize = CGSizeMake(CGRectGetWidth(bounds) - HEMCardOutsideMargin * 2, HEMCardDefaultItemHeight);
    self.sectionInset = UIEdgeInsetsMake(HEMCardOutsideMargin, 0, HEMCardOutsideMargin, 0);
    self.minimumInteritemSpacing = HEMCardInsideMargin;
    self.minimumLineSpacing = HEMCardInsideMargin;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    CGSize itemSize = self.itemSize;
    itemSize.height = itemHeight;
    self.itemSize = itemSize;
}

- (void)prepareLayout
{
    [super prepareLayout];
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:CGRectInset(self.collectionView.bounds, -100, -100)];
    NSString* key = NSStringFromSelector(@selector(indexPath));
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:key]];

    NSPredicate *removedPredicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        return [itemsIndexPathsInVisibleRectSet member:[[[behaviour items] firstObject] indexPath]] == nil;
    }];

    NSPredicate *visiblePredicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return [self.visibleIndexPathsSet member:item.indexPath] == nil;
    }];

    NSArray *noLongerVisibleBehaviours = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:removedPredicate];
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:visiblePredicate];

    for (id obj in noLongerVisibleBehaviours) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }

    for (UICollectionViewLayoutAttributes* item in newlyVisibleItems) {
        [self.visibleIndexPathsSet addObject:item.indexPath];
        UIAttachmentBehavior *behaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
        behaviour.length = HEMCardAttachmentLength;
        behaviour.damping = HEMCardAttachmentDamping;
        behaviour.frequency = HEMCardAttachmentFrequency;

        if (!CGPointEqualToPoint(CGPointZero, touchLocation))
            item.center = [self centerForTouchLocation:touchLocation behaviour:behaviour];

        [self.dynamicAnimator addBehavior:behaviour];
    }
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    for (UICollectionViewUpdateItem* item in updateItems) {
        if (item.updateAction == UICollectionUpdateActionDelete) {
            [self clearCache];
            break;
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGFloat delta = newBounds.origin.y - self.collectionView.bounds.origin.y;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];

    self.latestDelta = delta;

    for (UIAttachmentBehavior* springBehaviour in self.dynamicAnimator.behaviors) {
        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        item.center = [self centerForTouchLocation:touchLocation behaviour:springBehaviour];
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }

    return NO;
}

- (CGPoint)centerForTouchLocation:(CGPoint)touchLocation behaviour:(UIAttachmentBehavior*)springBehaviour
{
    CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
    CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehaviour.anchorPoint.x);
    CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / HEMCardResistanceCoefficient;
    UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
    CGPoint center = item.center;
    if (self.latestDelta < 0) {
        center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
    } else {
        center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
    }
    return center;
}

- (void)clearCache {
    [self.dynamicAnimator removeAllBehaviors];
    [self.visibleIndexPathsSet removeAllObjects];
}

@end
