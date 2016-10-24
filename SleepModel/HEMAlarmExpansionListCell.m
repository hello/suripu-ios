//
//  HEMAlarmExpansionListCell.m
//  Sense
//
//  Created by Jimmy Lu on 10/12/16.
//  Copyright © 2016 Hello. All rights reserved.
//

CGFloat const kHEMAlarmExpansionViewHeight = 42.0f;

static CGFloat const kHEMAlarmExpansionIconMargin = 18.0f;
static CGFloat const kHEMAlarmExpansionTextPadding = 14.0f;
static CGFloat const kHEMAlarmExpansionSeparatorHeight = 1.0f;

static NSInteger const kHEMAlarmExpansionTagIcon = 10;
static NSInteger const kHEMAlarmExpansionTagLabel = 11;

#import "HEMAlarmExpansionListCell.h"
#import "HEMStyle.h"

@interface HEMAlarmExpansionListCell()

@property (weak, nonatomic) IBOutlet UIView *expansionsContainer;

@end

@implementation HEMAlarmExpansionListCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [[[self expansionsContainer] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)showExpansionWithIcon:(UIImage*)icon
                         text:(NSAttributedString*)attributedText
                         tyep:(NSUInteger)type {
    
    NSInteger numberOfSubviews = [[[self expansionsContainer] subviews] count];
    CGFloat yOrigin = numberOfSubviews * kHEMAlarmExpansionViewHeight;
    UIView* expansionView = [[self expansionsContainer] viewWithTag:type];
    
    if (!expansionView) {
        expansionView = [self expansionViewWithYOrigin:yOrigin
                                                  icon:icon
                                                  text:attributedText
                                                   tag:type];
        [[self expansionsContainer] addSubview:expansionView];
    } else {
        UILabel* label = [expansionView viewWithTag:kHEMAlarmExpansionTagLabel];
        UIImageView* iconView = (id)[expansionView viewWithTag:kHEMAlarmExpansionTagIcon];
        
        [label setAttributedText:attributedText];
        [iconView setImage:icon];
    }
    
}

- (UIView*)expansionViewWithYOrigin:(CGFloat)yOrigin
                               icon:(UIImage*)icon
                               text:(NSAttributedString*)attributedText
                                tag:(NSUInteger)tag {
    CGFloat maxWidth = CGRectGetWidth([self bounds]);
    
    CGRect expansionFrame = CGRectZero;
    expansionFrame.size.width = maxWidth;
    expansionFrame.size.height = kHEMAlarmExpansionViewHeight;
    expansionFrame.origin.y = yOrigin;
    
    UIView* view = [[UIView alloc] initWithFrame:expansionFrame];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setTag:tag];
    
    CGRect separatorFrame = CGRectZero;
    separatorFrame.size.width = maxWidth;
    separatorFrame.size.height = kHEMAlarmExpansionSeparatorHeight;
    
    UIView* separator = [[UIView alloc] initWithFrame:separatorFrame];
    [separator setBackgroundColor:[UIColor separatorColor]];
    
    CGRect iconFrame = CGRectZero;
    iconFrame.size = icon.size;
    iconFrame.origin.x = kHEMAlarmExpansionIconMargin;
    iconFrame.origin.y = (kHEMAlarmExpansionViewHeight - icon.size.height) / 2.0f;
    UIImageView* iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    [iconView setImage:icon];
    [iconView setTag:kHEMAlarmExpansionTagIcon];
    
    CGFloat labelXOrigin = CGRectGetMaxX(iconFrame) + kHEMAlarmExpansionTextPadding;
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = labelXOrigin;
    labelFrame.size.height = kHEMAlarmExpansionViewHeight;
    labelFrame.size.width = maxWidth - labelXOrigin - kHEMAlarmExpansionIconMargin;
    
    UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setNumberOfLines:1];
    [label setAttributedText:attributedText];
    [label setTag:kHEMAlarmExpansionTagLabel];
    
    [view addSubview:separator];
    [view addSubview:iconView];
    [view addSubview:label];
    
    return view;
}

@end
