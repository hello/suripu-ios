//
//  HEMTimelineSummaryTitleLabel.m
//  Sense
//
//  Created by Delisa Mason on 6/13/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMTimelineSummaryTitleLabel.h"

@implementation HEMTimelineSummaryTitleLabel

- (void)awakeFromNib {
    NSDictionary *attributes = @{ NSKernAttributeName : @1 };
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
}

@end
