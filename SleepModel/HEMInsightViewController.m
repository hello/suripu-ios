//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENInsight.h>

#import "UIView+HEMSnapshot.h"
#import "HEMInsightViewController.h"
#import "HEMInsightCardView.h"

@interface HEMInsightViewController()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) HEMInsightCardView* insightCardView;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
}

- (void)setupBackground {
    if ([[self delegate] respondsToSelector:@selector(viewToShowThroughFrom:)]) {
        UIView* view = [[self delegate] viewToShowThroughFrom:self];
        UIColor* tint = [UIColor colorWithWhite:0.95f alpha:0.8f];
        UIImage* bgImage = [view blurredSnapshotWithTint:tint];
        [[self backgroundView] setImage:bgImage];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self setInsightCardView:[[HEMInsightCardView alloc] init]];
    [[self insightCardView] showInsightTitle:[[self insight] title]
                                 withMessage:[[self insight] message]
                                      inView:[self view]
                                  completion:nil
                                dismissBlock:^{
                                    __strong typeof(weakSelf) strongSelf = weakSelf;
                                    if (strongSelf) {
                                        [[strongSelf delegate] didDismissInsightFrom:strongSelf];
                                    }
                                }];
}

@end
