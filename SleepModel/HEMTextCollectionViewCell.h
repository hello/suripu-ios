//
//  HEMTextCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEMTextCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* textLabel;
@property (nonatomic, weak) IBOutlet UIView* separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;

+ (CGFloat)heightWithText:(NSString*)text font:(UIFont*)font cellWidth:(CGFloat)width;
- (void)displayAsACard:(BOOL)card;

@end
