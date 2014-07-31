
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CATransform3D.h>

#import "HEMZoomingFlowLayout.h"

CGFloat const ZOOM_FACTOR = 0.05f;
CGFloat const ACTIVE_DISTANCE = 20.f;

@implementation HEMZoomingFlowLayout

- (id)init
{
    if (self = [super init]) {
        //        self.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 250);
        //        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 1;
        self.minimumInteritemSpacing = 1;
    }

    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;

    for (UICollectionViewLayoutAttributes* attr in array) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attr.center.x;
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            if (ABS(distance) > ACTIVE_DISTANCE) {
                CGFloat zoom = 1 + ZOOM_FACTOR * (1 - ABS(normalizedDistance));
                attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attr.zIndex = round(zoom);
            }
        }
    }
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat center = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);

    CGRect targetRect = CGRectMake(0.0, proposedContentOffset.x, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];

    for (UICollectionViewLayoutAttributes* attr in array) {
        CGFloat itemCenter = attr.center.x;
        if (ABS(itemCenter - center) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemCenter - center;
        }
    }

    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
