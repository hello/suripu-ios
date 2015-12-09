//
//  HEMInsightTransition.h
//  Sense
//
//  Created by Jimmy Lu on 12/7/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "HEMTransitionDelegate.h"

@class HEMInsightCollectionViewCell;

@interface HEMInsightTransition : HEMTransitionDelegate

- (void)expandFrom:(HEMInsightCollectionViewCell*)cell withRelativeFrame:(CGRect)frame;

@end
