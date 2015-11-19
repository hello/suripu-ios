//
//  HEMExtendedHeaderCollectionViewLayout.m
//  Sense
//
//  Created by Jimmy Lu on 11/17/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMExtendedHeaderCollectionViewLayout.h"

@implementation HEMExtendedHeaderCollectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (UICollectionViewScrollDirection)scrollDirection {
    return UICollectionViewScrollDirectionVertical;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    UICollectionView *collectionView = [self collectionView];
    UIEdgeInsets insets = [collectionView contentInset];
    CGPoint offset = [collectionView contentOffset];
    CGFloat minY = -insets.top;
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    if (offset.y < minY) {

        CGFloat deltaY = fabs(offset.y - minY);
        
        for (UICollectionViewLayoutAttributes *attrs in attributes) {
            
            NSString *kind = [attrs representedElementKind];
            
            if (kind == UICollectionElementKindSectionHeader) {
                CGSize headerSize = [self headerReferenceSize];
                CGRect headerRect = [attrs frame];
                headerRect.size.height = MAX(minY, headerSize.height + deltaY);
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [attrs setFrame:headerRect];
                break;
            }
        }
    }
    return attributes;
}

@end
