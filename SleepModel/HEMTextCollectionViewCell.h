//
//  HEMTextCollectionViewCell.h
//  Sense
//
//  Created by Jimmy Lu on 2/6/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

@interface HEMTextCollectionViewCell : HEMCardCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* textLabel;
@property (nonatomic, weak) IBOutlet UIView* separator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBottomConstraint;

+ (UIFont*)defaultTextFont;
+ (CGFloat)heightWithText:(NSString*)text font:(UIFont*)font cellWidth:(CGFloat)width;
+ (CGFloat)heightWithAttributedText:(NSAttributedString*)text cellWidth:(CGFloat)width;
- (void)displayAsACard:(BOOL)card;

@end
