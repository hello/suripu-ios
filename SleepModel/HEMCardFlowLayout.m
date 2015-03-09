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
    [self updateBehaviorsForVisibleItems];
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

    for (UIAttachmentBehavior* springBehavior in self.dynamicAnimator.behaviors) {
        UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
        item.center = [self centerForTouchLocation:touchLocation behavior:springBehavior];
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }

    return NO;
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

- (void)updateBehaviorsForVisibleItems
{
    CGFloat baseInset = -100.0f;
    CGFloat dx = baseInset;
    CGFloat dy = baseInset + -([self footerReferenceSize].height + [self headerReferenceSize].height);
    
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:CGRectInset([[self collectionView] bounds], dx, dy)];
    NSString* key = NSStringFromSelector(@selector(indexPath));
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:key]];

    NSPredicate *removedPredicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings) {
        return [itemsIndexPathsInVisibleRectSet member:[[[behavior items] firstObject] indexPath]] == nil;
    }];

    NSPredicate *visiblePredicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return [self.visibleIndexPathsSet member:item.indexPath] == nil;
    }];

    NSArray *noLongerVisibleBehaviors = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:removedPredicate];
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:visiblePredicate];

    for (id obj in noLongerVisibleBehaviors) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }

    for (UICollectionViewLayoutAttributes* attributes in newlyVisibleItems) {
        [self addBehaviorToAttributes:attributes];
    }
}

- (void)addBehaviorToAttributes:(UICollectionViewLayoutAttributes *)item
{
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [self.visibleIndexPathsSet addObject:item.indexPath];
    UIAttachmentBehavior *behavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:item.center];
    behavior.length = HEMCardAttachmentLength;
    behavior.damping = HEMCardAttachmentDamping;
    behavior.frequency = HEMCardAttachmentFrequency;

    if (!CGPointEqualToPoint(CGPointZero, touchLocation))
        item.center = [self centerForTouchLocation:touchLocation behavior:behavior];

    [self.dynamicAnimator addBehavior:behavior];
}


- (CGPoint)centerForTouchLocation:(CGPoint)touchLocation behavior:(UIAttachmentBehavior*)springBehavior
{
    CGFloat yDistanceFromTouch = fabsf(touchLocation.y - springBehavior.anchorPoint.y);
    CGFloat xDistanceFromTouch = fabsf(touchLocation.x - springBehavior.anchorPoint.x);
    CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / HEMCardResistanceCoefficient;
    UICollectionViewLayoutAttributes *item = [springBehavior.items firstObject];
    CGPoint center = item.center;
    if (self.latestDelta < 0) {
        center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
    } else {
        center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
    }
    return center;
}

- (void)setFooterReferenceSizeFromText:(NSAttributedString*)text {
    UIEdgeInsets insets = [self sectionInset];
    CGSize footerConstraint = CGSizeZero;
    footerConstraint.width = [self itemSize].width;
    footerConstraint.height = MAXFLOAT;
    
    CGSize size = [text boundingRectWithSize:footerConstraint
                                     options:NSStringDrawingUsesFontLeading
                                            | NSStringDrawingUsesLineFragmentOrigin
                                     context:nil].size;
    size.height += insets.top + insets.bottom;
    
    [self setFooterReferenceSize:size];
}

- (void)clearCache {
    [self.dynamicAnimator removeAllBehaviors];
    [self.visibleIndexPathsSet removeAllObjects];
}

@end
