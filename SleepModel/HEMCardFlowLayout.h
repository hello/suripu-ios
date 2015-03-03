//
//  HEMCardFlowLayout.h
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMCardFlowLayout : UICollectionViewFlowLayout

- (void)setItemHeight:(CGFloat)itemHeight;
- (void)setFooterReferenceSizeFromText:(NSAttributedString*)text;
- (void)clearCache;

@end
