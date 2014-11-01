//
//  HEMInsightsSummaryDataSource.m
//  Sense
//
//  Created by Jimmy Lu on 10/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <SenseKit/SENAPIInsight.h>
#import <SenseKit/SENInsight.h>

#import "HEMInsightsSummaryDataSource.h"
#import "HEMInsightCollectionViewCell.h"

static NSString* const kHEMInsightCellReuseId = @"insight";
static CGFloat const kHEMInsightCellDisplayDuration = 1.0f;

@interface HEMInsightsSummaryDataSource()

@property (nonatomic, strong) NSArray* insights;

@end

@implementation HEMInsightsSummaryDataSource

- (id)initWithCollectionView:(UICollectionView*)collectionView {
    self = [super init];
    if (self) {
        [collectionView registerClass:[HEMInsightCollectionViewCell class]
           forCellWithReuseIdentifier:kHEMInsightCellReuseId];
    }
    return self;
}

- (void)refreshInsights:(void(^)(void))completion {
    __weak typeof(self) weakSelf = self;
    [SENAPIInsight getInsights:^(NSArray* insights, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error == nil) {
                [strongSelf setInsights:insights];
            }
            if (completion) completion ();
        }
    }];
}

- (BOOL)hasInsights {
    return [[self insights] count] > 0;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return [[self insights] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SENInsight* insight = [self insights][[indexPath row]];
    
    HEMInsightCollectionViewCell* cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kHEMInsightCellReuseId
                                                  forIndexPath:indexPath];
    
    [cell setTitle:[[insight title] uppercaseString] message:[insight message]];
    
    [[cell contentView ] setAlpha:0.0f];
    [UIView animateWithDuration:kHEMInsightCellDisplayDuration animations:^{
        [[cell contentView ] setAlpha:1.0f];
    }];
    
    return cell;
}

@end
