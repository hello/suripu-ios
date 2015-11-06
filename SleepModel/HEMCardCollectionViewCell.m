//
//  HEMCardCollectionViewCell.m
//  Sense
//
//  Created by Delisa Mason on 12/15/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMCardCollectionViewCell.h"
#import "HelloStyleKit.h"
#import "UIColor+HEMStyle.h"
#import "HEMActivityCoverView.h"

@interface HEMCardCollectionViewCell()

@property (nonatomic, weak) HEMActivityCoverView* activityView;

@end

@implementation HEMCardCollectionViewCell

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)awakeFromNib
{
    NSShadow* shadow = [HelloStyleKit backViewCardShadow];

    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.contentView.layer.cornerRadius = 3.f;
    self.contentView.layer.borderColor = [[UIColor cardBorderColor] CGColor];
    self.contentView.layer.borderWidth = 1.f;
    self.contentView.layer.shadowOffset = [shadow shadowOffset];
    self.contentView.layer.shadowColor = [[shadow shadowColor] CGColor];
    self.contentView.layer.shadowRadius = [shadow shadowBlurRadius];
    self.contentView.layer.shadowOpacity = 1.f;
    self.contentView.layer.masksToBounds = YES;
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
