//
//  HEMAlarmExpansionListCell.h
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMAlarmListCell.h"

extern CGFloat const kHEMAlarmExpansionViewHeight;

@interface HEMAlarmExpansionListCell : HEMAlarmListCell

@property (weak, nonatomic) IBOutlet UIView* expansionSeparator;
@property (weak, nonatomic) IBOutlet UIImageView* expansionIconView;
@property (weak, nonatomic) IBOutlet UILabel* expansionLabel;

+ (NSDictionary*)attributesForExpansionValueText:(BOOL)enabled;
+ (NSDictionary*)attributesForExpansionText:(BOOL)enabled;
- (void)showExpansionWithIcon:(UIImage*)icon
                         text:(NSAttributedString*)attributedText
                         tyep:(NSUInteger)type;

@end
