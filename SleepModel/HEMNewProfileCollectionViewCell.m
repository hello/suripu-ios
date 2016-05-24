//
//  HEMNewProfileCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 5/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMNewProfileCollectionViewCell.h"

@implementation HEMNewProfileCollectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect autofillFrame = [[self fbAutofillButton] frame];
    CGRect fbInfoFrame = [[self fbInfoButton] frame];
    if (CGRectIntersectsRect(autofillFrame, fbInfoFrame)) {
        DDLogVerbose(@"uh oh, overlapping buttons!");
    }
}

@end
