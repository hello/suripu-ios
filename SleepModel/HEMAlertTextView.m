//
//  HEMAlertTextView.m
//  Sense
//
//  Created by Delisa Mason on 10/5/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "Sense-Swift.h"
#import "HEMAlertTextView.h"

@implementation HEMAlertTextView

- (instancetype)init {
    if (self = [super init]) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureDefaults];
    }
    return self;
}

- (void)configureDefaults {
    UIColor* linkColor = [SenseStyle colorWithAClass:[self class] property:ThemePropertyLinkColor];
    UIFont* linkFont = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    
    self.editable = NO;
    self.scrollEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypeAddress;
    self.linkTextAttributes = @{NSForegroundColorAttributeName : linkColor,
                                NSFontAttributeName : linkFont};
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
}

@end
