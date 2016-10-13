//
//  HEMVoiceExamplesPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//

#import "HEMVoiceExamplesPresenter.h"
#import "HEMVoiceCommandGroup.h"
#import "HEMVoiceGroupHeaderCell.h"
#import "HEMVoiceExampleGroupCell.h"
#import "HEMMainStoryboard.h"
#import "HEMStyle.h"

@interface HEMVoiceExamplesPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) HEMVoiceCommandGroup* group;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UINavigationBar* navBar;

@end

@implementation HEMVoiceExamplesPresenter

- (instancetype)initWithCommandGroup:(HEMVoiceCommandGroup*)group {
    if (self = [super init]) {
        _group = group;
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [self setCollectionView:collectionView];
}

- (void)bindWithNavigationBar:(UINavigationBar*)navBar {
    [navBar setShadowImage:[UIImage new]];
    [self setNavBar:navBar];
}

- (BOOL)hasNavBar {
    return [self navBar] != nil;
}

#pragma mark - Presenter Events

- (void)wasRemovedFromParent {
    [super wasRemovedFromParent];
    if (_navBar) {
        [_navBar setShadowImage:[UIImage imageNamed:@"navBorder"]];
    }
}

#pragma mark - UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewFlowLayout* layout = (id) collectionViewLayout;
    CGSize itemSize = [layout itemSize];
    itemSize.width = CGRectGetWidth([[collectionView superview] bounds]);
    
    if ([indexPath row] == 0) {
        itemSize.height = [HEMVoiceGroupHeaderCell heightWithCategory:[[self group] categoryName]
                                                         categoryFont:[UIFont h5]
                                                              message:[[self group] message]
                                                          messageFont:[UIFont body]
                                                            fullWidth:itemSize.width];
    }
    
    return itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[[self group] examples] count] + 1; // 1 for header
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    NSString* reuseId = nil;
    if (row == 0) {
        reuseId = [HEMMainStoryboard commandGroupReuseIdentifier];
    } else {
        reuseId = [HEMMainStoryboard examplesReuseIdentifier];
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:reuseId
                                                     forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[HEMVoiceGroupHeaderCell class]]) {
        HEMVoiceGroupHeaderCell* headerCell = (id) cell;
        [[headerCell imageView] setImage:[UIImage imageNamed:[[self group] iconNameLarge]]];
        [[headerCell categoryLabel] setText:[[self group] categoryName]];
        [[headerCell categoryLabel] setFont:[UIFont h5]];
        [[headerCell categoryLabel] setTextColor:[UIColor grey6]];
        
        [[headerCell messageLabel] setText:[[self group] message]];
        [[headerCell messageLabel] setFont:[UIFont body]];
        [[headerCell messageLabel] setTextColor:[UIColor grey5]];
    }
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDataSource:nil];
        [_collectionView setDelegate:nil];
    }
}

@end
