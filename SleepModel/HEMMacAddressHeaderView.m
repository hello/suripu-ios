//
//  HEMMacAddressHeaderView.m
//  Sense
//
//  Created by Jimmy Lu on 10/14/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "HEMMacAddressHeaderView.h"

@implementation HEMMacAddressHeaderView
    
- (void)awakeFromNib {
    [super awakeFromNib];
    [self applyFillStyle];
}
    
- (void)applyFillStyle {
    [super applyFillStyle];
    [[self titleLabel] setFont:[SenseStyle fontWithAClass:[self class]
                                                property:ThemePropertyTitleFont]];
    [[self titleLabel] setTextColor:[SenseStyle colorWithAClass:[self class]
                                                       property:ThemePropertyTitleColor]];
    [[self actionButton] applySecondaryStyle];
}

@end
