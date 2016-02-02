//
//  HEMTrendsBaseCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@interface HEMTrendsBaseCell : HEMCardCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UIView* titleSeparator;
@property (nonatomic, weak) IBOutlet UIView* bodyContainerView;

@end
