//
//  HEMSleepGraphView.h
//  Sense
//
//  Created by Delisa Mason on 12/4/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HEMEventInfoView;
@class SENSleepResultSegment;

@interface HEMSleepGraphView : UIView

- (void)positionEventInfoViewRelativeToView:(UIView*)view
                                withSegment:(SENSleepResultSegment*)segment
                          totalSegmentCount:(NSUInteger)segmentCount;
- (void)hideEventInfoView;

- (void)addVerifyDataTarget:(id)target action:(SEL)action;

@property (strong, nonatomic) HEMEventInfoView* eventInfoView;
@property (weak, nonatomic) UICollectionView* collectionView;
@end
