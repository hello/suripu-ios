//
//  HEMTutorialDataSource.h
//  Sense
//
//  Created by Jimmy Lu on 6/9/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HEMTutorialContent;

@interface HEMTutorialDataSource : NSObject <UICollectionViewDataSource>

- (instancetype)initWithContent:(HEMTutorialContent*)content
              forCollectionView:(UICollectionView*)collectionView;

- (CGSize)sizeForContentAtIndexPath:(NSIndexPath*)indexPath;
- (CGFloat)contentSpacingAtSection:(NSInteger)section;
- (UIEdgeInsets)contentInsetAtSection:(NSInteger)section;

@end
