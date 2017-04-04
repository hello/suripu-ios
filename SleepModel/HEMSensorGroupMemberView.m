//
//  HEMSensorGroupMemberView.m
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import "Sense-Swift.h"
#import "NSBundle+HEMUtils.h"

#import "HEMSensorGroupMemberView.h"

@interface HEMSensorGroupMemberView()

@property (nonatomic, weak) UITapGestureRecognizer* tap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end

@implementation HEMSensorGroupMemberView

+ (instancetype)defaultInstance {
    return [NSBundle loadNibWithOwner:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer* tap = [UITapGestureRecognizer new];
    [self addGestureRecognizer:tap];
    [self setTap:tap];
    [self setDefaults];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    UIFont* font = [SenseStyle fontWithAClass:[self class] property:ThemePropertyTextFont];
    UIColor* color = [SenseStyle colorWithAClass:[self class] property:ThemePropertyTextColor];
    [[self nameLabel] setFont:font];
    [[self nameLabel] setTextColor:color];
    [[self valueLabel] setFont:font];
    
    [[self separatorView] applySeparatorStyle];
}

@end
