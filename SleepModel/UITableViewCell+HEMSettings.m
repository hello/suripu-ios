//
//  UITableViewCell+HEMSettings.m
//  Sense
//
//  Created by Jimmy Lu on 11/23/15.
//  Copyright © 2015 Hello. All rights reserved.
//

#import "UITableViewCell+HEMSettings.h"

static NSUInteger const HEMSettingsToggleTag = 101;

@implementation UITableViewCell (HEMSettings)

- (UIImageView*)selectionAccessoryView:(BOOL)selected {
    UIImage* activeToggleImage = [UIImage imageNamed:@"settingsToggleIconActive"];
    UIImage* inactiveToggleImage = [UIImage imageNamed:@"settingsToggleIconInactive"];
    UIImageView* toggleView = [[UIImageView alloc] initWithImage:inactiveToggleImage
                                                highlightedImage:activeToggleImage];
    
    CGRect toggleFrame = CGRectZero;
    toggleFrame.size = [activeToggleImage size];
    [toggleView setFrame:toggleFrame];
    
    [toggleView setHighlighted:selected];
    
    return toggleView;
}

- (void)setAccessorySelection:(BOOL)selected {
    UIImageView* toggle = nil;
    if ([[self accessoryView] tag] == HEMSettingsToggleTag) {
        UIImageView* toggle = (id)[self accessoryView];
        [toggle setHighlighted:YES];
    } else {
        toggle = [self selectionAccessoryView:selected];
        [self setAccessoryView:toggle];
    }
}

@end
