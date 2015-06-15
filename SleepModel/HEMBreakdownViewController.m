//
//  HEMBreakdownViewController.m
//  Sense
//
//  Created by Delisa Mason on 6/15/15.
//  Copyright (c) 2015 Hello. All rights reserved.
//

#import "HEMBreakdownViewController.h"
#import "HEMMainStoryboard.h"

@interface HEMBreakdownViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@end

@implementation HEMBreakdownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)dismissFromView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        HEMBreakdownSummaryCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard summaryViewCellReuseIdentifier]
                                                                                  forIndexPath:indexPath];
        cell.detailLabel.text = self.result.message;
        return cell;
    } else {
        HEMBreakdownLineCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HEMMainStoryboard breakdownLineCellReuseIdentifier]
                                                                               forIndexPath:indexPath];
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const CGFloat BreakdownCellHeight = 96.f;
    return CGSizeMake(CGRectGetWidth(self.view.bounds), BreakdownCellHeight);
}

@end

@implementation HEMBreakdownSummaryCell
@end

@implementation HEMBreakdownLineCell
@end
