//
//  HEMVoiceExampleView.m
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceExampleView.h"
#import "NSBundle+HEMUtils.h"
#import "HEMStyle.h"

@implementation HEMVoiceExampleView

+ (instancetype)exampleViewWithCategoryName:(NSString*)name
                                    example:(NSString*)example
                                  iconImage:(UIImage*)iconImage {
    HEMVoiceExampleView* view = [NSBundle loadNibWithOwner:self];
    [[view categoryLabel] setText:name];
    [[view exampleLabel] setText:example];
    [[view iconView] setImage:iconImage];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[self categoryLabel] setTextColor:[UIColor grey6]];
    [[self categoryLabel] setFont:[UIFont body]];
    [[self exampleLabel] setTextColor:[UIColor grey4]];
    [[self exampleLabel] setFont:[UIFont bodySmall]];
    [[self exampleLabel] setNumberOfLines:0];
    [[self iconView] setContentMode:UIViewContentModeCenter];
    [[self separatorView] setBackgroundColor:[UIColor separatorColor]];
    
    UITapGestureRecognizer* tap = [UITapGestureRecognizer new];
    [self addGestureRecognizer:tap];
    [self setTapGesture:tap];
}

@end
