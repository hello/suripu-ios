//
//  HEMRoomConditionsPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 8/30/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMRoomConditionsPresenter.h"
#import "HEMSensorService.h"
#import "HEMIntroService.h"
#import "HEMDescriptionHeaderView.h"
#import "HEMStyle.h"

@interface HEMRoomConditionsPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) HEMSensorService* sensorService;
@property (nonatomic, weak) HEMIntroService* introService;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat headerViewHeight;

@end

@implementation HEMRoomConditionsPresenter

- (instancetype)initWithSensorService:(HEMSensorService*)sensorService
                         introService:(HEMIntroService*)introService {
    self = [super init];
    if (self) {
        _sensorService = sensorService;
        _introService = introService;
        _headerViewHeight = -1.0f;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setBackgroundColor:[UIColor grey2]];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [self setCollectionView:collectionView];
}

#pragma mark - Presenter Events

- (void)didAppear {
    [super didAppear];
    [[self introService] incrementIntroViewsForType:HEMIntroTypeRoomConditions];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeZero;
    if ([[self introService] shouldIntroduceType:HEMIntroTypeRoomConditions]) {
        if ([self headerViewHeight] < 0.0f) {
            NSString* title = NSLocalizedString(@"room-conditions.intro.title", nil);
            NSString* message = NSLocalizedString(@"room-conditions.intro.desc", nil);
            CGFloat cellWidth = CGRectGetWidth([collectionView bounds]);
            
        }
    }
    return headerSize;
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDelegate:nil];
        [_collectionView setDataSource:nil];
    }
}

@end
