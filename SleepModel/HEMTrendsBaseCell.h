//
//  HEMTrendsBaseCell.h
//  Sense
//
//  Created by Jimmy Lu on 1/29/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"

@class HEMTrendsAverageView;

@interface HEMTrendsBaseCell : HEMCardCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UIView* titleSeparator;
@property (nonatomic, weak) IBOutlet HEMTrendsAverageView *averagesView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *averagesHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *averagesBottomConstraint;

@property (nonatomic, strong) UIColor* averageValueColor;
@property (nonatomic, strong) UIColor* averageTitleColor;

- (void)setAverageTitles:(NSArray<NSString*>*)titles
                  values:(NSArray<NSString*>*)values;

@end
