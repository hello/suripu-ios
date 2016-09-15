//
//  HEMSensorGroupMemberView.m
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSBundle+HEMUtils.h"

#import "HEMSensorGroupMemberView.h"
#import "HEMStyle.h"

@implementation HEMSensorGroupMemberView

+ (instancetype)defaultInstance {
    return [NSBundle loadNibWithOwner:self];
}

- (void)awakeFromNib {
    [[self nameLabel] setTextColor:[UIColor grey6]];
    [[self nameLabel] setFont:[UIFont body]];
    [[self valueLabel] setFont:[UIFont body]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    [[self nameLabel] setFont:[UIFont body]];
    [[self nameLabel] setTextColor:[UIColor grey6]];
    [[self valueLabel] setFont:[UIFont body]];
}

@end
