
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CATransform3D.h>

#import "HEMZoomingFlowLayout.h"

@implementation HEMZoomingFlowLayout

CGFloat const HEMZoomLevel = 0.03f;
CGFloat const HEMZoomActiveDistance = 20.f;

- (id)init
{
    if (self = [super init]) {
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
            CGFloat normalizedDistance = distance / HEMZoomActiveDistance;
            attr.alpha = MAX(1/(ABS(distance)/HEMZoomActiveDistance), 0.4);
            if (ABS(distance) > HEMZoomActiveDistance) {
                CGFloat zoom = 1 + HEMZoomLevel * (1 - ABS(normalizedDistance));
                attr.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attr.zIndex = round(zoom);
            }
        }
    }
    return array;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat contentWidth = self.collectionView.contentSize.width;
    CGFloat scrollWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat itemtWidth = self.itemSize.width;
    if (proposedContentOffset.x == contentWidth - scrollWidth + itemtWidth){
        return proposedContentOffset;
    }
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x - 10;

    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));

    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];

    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }

    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end
