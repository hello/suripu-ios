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

- (SENInsight*)insightAtIndexPath:(NSIndexPath*)indexPath {
    DDLogVerbose(@"row %ld", [indexPath row]);
    return [indexPath row] < [[self insights] count] ? [self insights][[indexPath row]] : nil;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSInteger insightCount = [[self insights] count];
    return insightCount > 0 ? insightCount : 1; // display description of what it is
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEMInsightCollectionViewCell* cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kHEMInsightCellReuseId
                                              forIndexPath:indexPath];
    
    SENInsight* insight = [self insightAtIndexPath:indexPath];
    if (insight != nil) {
        [cell setTitle:[[insight title] uppercaseString] message:[insight message]];

    } else {
        [cell setTitle:NSLocalizedString(@"sleep.insight.title", nil)
               message:NSLocalizedString(@"sleep.insight.summary.no-data-message", nil)];
    }
    
    cell.layer.cornerRadius = 2.f;
    cell.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1f].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 0.5);
    cell.layer.shadowOpacity = 1.f;
    cell.layer.shadowRadius = 1.f;
    return cell;
}

@end
