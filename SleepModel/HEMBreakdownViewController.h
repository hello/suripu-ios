//
//  HEMBreakdownViewController.h
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SENTimeline;
@interface HEMBreakdownViewController : UIViewController

@property (nonatomic, strong) SENTimeline* result;
@end

@interface HEMBreakdownSummaryCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* detailLabel;
@end

@interface HEMBreakdownLineCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel* itemTitle1;
@property (nonatomic, weak) IBOutlet UILabel* itemTitle2;
@property (nonatomic, weak) IBOutlet UILabel* itemValue1;
@property (nonatomic, weak) IBOutlet UILabel* itemValue2;

@end