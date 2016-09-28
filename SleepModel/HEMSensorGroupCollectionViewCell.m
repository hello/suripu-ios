//
//  HEMSensorGroupCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMSensorGroupCollectionViewCell.h"
#import "HEMSensorGroupMemberView.h"

static CGFloat const HEMSensorGroupCellBaseHeight = 74.0f;
static CGFloat const HEMSensorGroupMemberHeight = 56.0f;

@interface HEMSensorGroupCollectionViewCell()

@property (nonatomic, strong) NSCache* memberViewCache;

@end

@implementation HEMSensorGroupCollectionViewCell

+ (CGFloat)heightWithNumberOfMembers:(NSInteger)memberCount {
    return HEMSensorGroupCellBaseHeight + (HEMSensorGroupMemberHeight * memberCount);
}

- (void)prepareForReuse {
    [[[self sensorContentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (HEMSensorGroupMemberView*)addSensorWithName:(NSString*)name
                                         value:(NSString*)valueText
                                    valueColor:(UIColor*)valueColor {
    if (![self memberViewCache]) {
        [self setMemberViewCache:[NSCache new]];
        [[self memberViewCache] setCountLimit:3];
    }
    
    HEMSensorGroupMemberView* memberView = [[self memberViewCache] objectForKey:name];
    if (!memberView) {
        memberView = [HEMSensorGroupMemberView defaultInstance];
        [memberView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self memberViewCache] setObject:memberView forKey:name];
    }
    
    [[memberView nameLabel] setText:name];
    [[memberView valueLabel] setText:valueText];
    [[memberView valueLabel] setTextColor:valueColor];
    
    NSInteger memberCount = [[[self sensorContentView] subviews] count];
    CGRect memberFrame = CGRectZero;
    memberFrame.size.width = CGRectGetWidth([[self sensorContentView] bounds]);
    memberFrame.size.height = HEMSensorGroupMemberHeight;
    memberFrame.origin.y = memberCount * HEMSensorGroupMemberHeight;
    [memberView setFrame:memberFrame];
    
    [[self sensorContentView] addSubview:memberView];
    
    return memberView;
}

@end
