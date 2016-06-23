//
//  HEMInsightSummaryView.h
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

@class HEMURLImageView;

extern CGFloat const HEMInsightCellMessagePadding;

NS_ASSUME_NONNULL_BEGIN

@interface HEMInsightCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *imageContainer;
@property (weak, nonatomic) IBOutlet HEMURLImageView *uriImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

+ (CGFloat)contentHeightWithMessage:(NSAttributedString*)message
                            inWidth:(CGFloat)contentWidth
                          shareable:(BOOL)shareable;

- (void)enableShare:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
