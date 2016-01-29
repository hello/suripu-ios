//
//  HEMTrendsV2ViewController.m
//  Sense
//
//  Created by Jimmy Lu on 1/28/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMTrendsV2ViewController.h"
#import "HEMTrendsScopeSelectorPresenter.h"
#import "HEMTrendsService.h"

@interface HEMTrendsV2ViewController()

@property (nonatomic, strong) HEMTrendsService* trendsService;
@property (weak, nonatomic) IBOutlet UIView *scopeSelectorContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectorHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation HEMTrendsV2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePresenters];
}

- (void)configurePresenters {
    HEMTrendsService* service = [HEMTrendsService new];
    HEMTrendsScopeSelectorPresenter* scopePresenter
        = [[HEMTrendsScopeSelectorPresenter alloc] initWithTrendsService:service];
    [scopePresenter bindWithSelectorContainer:[self scopeSelectorContainer]
                         withHeightConstraint:[self selectorHeightConstraint]];
    
    [self addPresenter:scopePresenter];
    [self setTrendsService:service];
}

@end
