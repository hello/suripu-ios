//
//  HEMFbAutofillButton.m
//  Sense
//
//  Created by Jimmy Lu on 5/19/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMFbAutofillButton.h"
#import "HEMStyle.h"

static CGFloat const HEMFbAutofillCornerRadius = 3.0f;
static CGFloat const HEMFbAutofillBorderWidth = 1.0f;

@implementation HEMFbAutofillButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureAppearances];
    }
    return self;
}

- (void)configureAppearances {
    CALayer* buttonLayer = [self layer];
    [buttonLayer setCornerRadius:HEMFbAutofillCornerRadius];
    [buttonLayer setBorderColor:[[UIColor borderColor] CGColor]];
    [buttonLayer setBorderWidth:HEMFbAutofillBorderWidth];
    
    [self setTitleColor:[UIColor grey3] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor grey3] forState:UIControlStateSelected];
    [self setAdjustsImageWhenHighlighted:NO];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor* autofillBgColor = highlighted ? [UIColor grey1] : [UIColor whiteColor];
    [self setBackgroundColor:autofillBgColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self setImage:[UIImage imageNamed:@"fbIconGrey"]
              forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grey3] forState:UIControlStateNormal];
    }
}

@end
