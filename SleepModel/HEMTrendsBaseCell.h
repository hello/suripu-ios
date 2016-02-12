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
@property (nonatomic, assign, getter=isLoading) BOOL loading;

- (void)setAverageTitles:(NSArray<NSAttributedString*>*)titles
                  values:(NSArray<NSAttributedString*>*)values;

@end
