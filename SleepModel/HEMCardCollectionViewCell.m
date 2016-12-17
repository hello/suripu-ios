//
//  HEMCardCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "UIColor+HEMStyle.h"
#import "NSShadow+HEMStyle.h"
#import "UICollectionViewCell+HEMCard.h"

#import "HEMCardCollectionViewCell.h"
#import "HEMActivityCoverView.h"

@interface HEMCardCollectionViewCell()

@property (nonatomic, weak) HEMActivityCoverView* activityView;

@end

@implementation HEMCardCollectionViewCell

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self displayAsACard:YES];
}

- (void)showActivity:(BOOL)show withText:(NSString*)text {
    if (show) {
        HEMActivityCoverView* activityView = [HEMActivityCoverView new];
        [activityView showInView:[self contentView] withText:text activity:YES completion:nil];
        [self setActivityView:activityView];
    } else {
        [[self activityView] removeFromSuperview];
    }
}

@end
