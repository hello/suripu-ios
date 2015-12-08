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

@property (weak, nonatomic) IBOutlet HEMURLImageView *uriImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

+ (CGFloat)contentHeightWithMessage:(NSAttributedString*)message
                            inWidth:(CGFloat)contentWidth;

@end

NS_ASSUME_NONNULL_END
