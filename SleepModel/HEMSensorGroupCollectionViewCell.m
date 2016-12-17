//
//  HEMSensorGroupCollectionViewCell.m
//  Sense
//
//  Created by Jimmy Lu on 9/9/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "NSString+HEMUtils.h"

#import "HEMSensorGroupCollectionViewCell.h"
#import "HEMSensorGroupMemberView.h"

static CGFloat const HEMSensorGroupCellBaseHeight = 56.0f;
static CGFloat const HEMSensorGroupMemberHeight = 56.0f;
static CGFloat const HEMSensorGroupLabelMargin = 16.0f;

@interface HEMSensorGroupCollectionViewCell()

@property (nonatomic, strong) NSCache* memberViewCache;

@end

@implementation HEMSensorGroupCollectionViewCell

+ (CGFloat)heightWithNumberOfMembers:(NSInteger)memberCount
                       conditionText:(NSString*)conditionText
                       conditionFont:(UIFont*)conditionFont
                           cellWidth:(CGFloat)cellWidth {
    CGFloat maxLabelWidth = cellWidth - (2 * HEMSensorGroupLabelMargin);
    CGFloat conditionHeight = [conditionText heightBoundedByWidth:maxLabelWidth usingFont:conditionFont];
    return HEMSensorGroupCellBaseHeight + conditionHeight + (HEMSensorGroupMemberHeight * memberCount);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [[[self sensorContentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    DDLogVerbose(@"removed content views");
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
    DDLogVerbose(@"added content view %@", name);
    
    return memberView;
}

@end
