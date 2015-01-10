//
//  HEMTrendsViewController.m
//  Sense
//
//  Created by Delisa Mason on 12/13/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import "HEMTrendsViewController.h"
#import "HelloStyleKit.h"
#import "HEMMainStoryboard.h"
#import "HEMCardFlowLayout.h"

@interface HEMTrendsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) IBOutlet UICollectionView* collectionView;
@end

@implementation HEMTrendsViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem.image = [HelloStyleKit trendsBarIcon];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView setAlwaysBounceVertical:YES];
    HEMCardFlowLayout* layout = (id)self.collectionView.collectionViewLayout;
    [layout setItemHeight:235];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* identifier = [HEMMainStoryboard overTimeReuseIdentifier];
    return [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
}

@end
