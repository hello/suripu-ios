//
//  HEMEmptyTrendCollectionViewCell.h
//  Sense
//
//  Created by Delisa Mason on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HEMCardCollectionViewCell.h"

@interface HEMEmptyTrendCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *illustrationView;
@property (weak, nonatomic) IBOutlet UILabel* detailLabel;

+ (CGFloat)heightWithDescription:(NSString*)description cellWidth:(CGFloat)width;

@end
