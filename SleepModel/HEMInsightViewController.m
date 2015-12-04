//
//  HEMInsightViewController.m
//  Sense
//
//  Created by Jimmy Lu on 11/11/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMInsightViewController.h"
#import "HEMInsightsService.h"
#import "HEMInsightPresenter.h"


@interface HEMInsightViewController()

@property (weak, nonatomic) IBOutlet UICollectionView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (strong, nonatomic) HEMInsightsService* insightService;

@end

@implementation HEMInsightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenter];
    [SENAnalytics track:kHEMAnalyticsEventInsight];
}

- (void)configurePresenter {
    HEMInsightsService* service = [HEMInsightsService new];
    HEMInsightPresenter* presenter = [[HEMInsightPresenter alloc] initWithInsightService:service
                                                                              forInsight:[self insight]];
    [presenter bindWithCollectionView:[self contentView]];
    [self addPresenter:presenter];
    [self setInsightService:service];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
