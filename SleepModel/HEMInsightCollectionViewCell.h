//
//  HEMInsightSummaryView.h
//  Sense
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HEMCardCollectionViewCell.h"

extern CGFloat const HEMInsightCellMessagePadding;

@interface HEMInsightCollectionViewCell : HEMCardCollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

+ (NSAttributedString*)attributedTextForMessage:(NSString*)message;
+ (CGFloat)contentHeightWithMessage:(NSString*)message
                        infoPreview:(NSString*)infoPreview
                            inWidth:(CGFloat)contentWidth;
- (void)setMessage:(NSString*)message;
- (void)setTitle:(NSString*)title;
- (void)setInfoPreview:(NSString*)infoPreview;

@end
