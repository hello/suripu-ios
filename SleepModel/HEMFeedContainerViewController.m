//
//  HEMFeedContainerViewController.m
//  Sense
//
//  Created by Jimmy Lu on 10/10/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMFeedContainerViewController.h"
#import "HEMSubNavigationView.h"
#import "HEMActivityIndicatorView.h"

@interface HEMFeedContainerViewController ()

@property (weak, nonatomic) IBOutlet HEMSubNavigationView *subNav;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *errorCollectionView;
@property (weak, nonatomic) IBOutlet HEMActivityIndicatorView *activityIndicatorView;

@end

@implementation HEMFeedContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
