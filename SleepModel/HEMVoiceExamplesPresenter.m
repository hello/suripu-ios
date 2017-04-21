//
//  HEMVoiceExamplesPresenter.m
//  Sense
//
//  Created by Jimmy Lu on 10/13/16.
//  Copyright © 2016 Hello. All rights reserved.
//
#import <SenseKit/SENVoiceCommandGroup.h>
#import <SenseKit/SENRemoteImage.h>

#import "Sense-Swift.h"
#import "SENRemoteImage+HEMDeviceSpecific.h"

#import "HEMVoiceExamplesPresenter.h"
#import "HEMVoiceGroupHeaderCell.h"
#import "HEMVoiceExampleGroupCell.h"
#import "HEMMainStoryboard.h"

static CGFloat const kHEMVoiceExamplesBottomInset = 20.0f;

@interface HEMVoiceExamplesPresenter() <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) SENVoiceCommandGroup* group;
@property (nonatomic, weak) UICollectionView* collectionView;
@property (nonatomic, weak) UINavigationBar* navBar;
@property (nonatomic, strong) NSDictionary* examplesBodyAttributes;
@property (nonatomic, copy) NSArray<NSAttributedString*>* appendedCommands;

@end

@implementation HEMVoiceExamplesPresenter

- (instancetype)initWithCommandGroup:(SENVoiceCommandGroup*)group {
    if (self = [super init]) {
        _group = group;
        [self prepareCommands];
    }
    return self;
}

- (void)bindWithCollectionView:(UICollectionView*)collectionView {
    UICollectionViewFlowLayout* layout = (id) [collectionView collectionViewLayout];
    [layout setSectionInset:UIEdgeInsetsMake(0.0f, 0.0f, kHEMVoiceExamplesBottomInset, 0.0f)];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    [collectionView applyFillStyle];
    [self setCollectionView:collectionView];
}

- (void)bindWithNavigationBar:(UINavigationBar*)navBar {
    [navBar setShadowImage:[UIImage new]];
    [self setNavBar:navBar];
}

- (BOOL)hasNavBar {
    return [self navBar] != nil;
}

- (void)prepareCommands {
    [self setExamplesBodyAttributes:[HEMVoiceExampleGroupCell examplesAttributes]];
    
    NSUInteger count = [[[self group] groups] count];
    NSUInteger index = 0;
    NSMutableArray* appendedCommands = [NSMutableArray arrayWithCapacity:count];
    for (SENVoiceCommandSubGroup* subGroup in [[self group] groups]) {
        NSMutableString* groupCommands = [NSMutableString new];
        for (NSString* command in [subGroup commands]) {
            if ([groupCommands length] > 0) {
                [groupCommands appendFormat:@"\n%@", command];
            } else {
                [groupCommands appendString:command];
            }
        }
        NSAttributedString* attrGroupCommands =
            [[NSAttributedString alloc] initWithString:groupCommands
                                            attributes:[self examplesBodyAttributes]];
        [appendedCommands addObject:attrGroupCommands];
        index++;
    }
    [self setAppendedCommands:appendedCommands];
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
        itemSize.height = [HEMVoiceGroupHeaderCell heightWithCategory:[[self group] localizedTitle]
                                                              message:[[self group] localizedExample]
                                                            fullWidth:itemSize.width];
    } else {
        SENVoiceCommandSubGroup* commandGroup = [[self group] groups][[indexPath row] -1];
        NSString* groupCategoryName = [commandGroup localizedTitle];
        NSAttributedString* groupCommands = [self appendedCommands][[indexPath row] - 1];
        itemSize.height = [HEMVoiceExampleGroupCell heightWithCategoryName:groupCategoryName
                                                                  examples:groupCommands
                                                                 cellWidth:itemSize.width];
    }
    
    return itemSize;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [[self appendedCommands] count] + 1; // 1 for header
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
        [self configureHeaderCell:(id)cell];
    } else if ([cell isKindOfClass:[HEMVoiceExampleGroupCell class]]) {
        [self configureExamplesCell:(id)cell atRow:[indexPath row]];
    }
}

- (void)configureHeaderCell:(HEMVoiceGroupHeaderCell*)headerCell {
    SENRemoteImage* image = [[self group] iconImage];
    [[headerCell imageView] setImageWithURL:[image uriForCurrentDevice]];
    [[headerCell categoryLabel] setText:[[self group] localizedTitle]];
    [[headerCell messageLabel] setText:[[self group] localizedExample]];
    [headerCell applyStyle];
}

- (void)configureExamplesCell:(HEMVoiceExampleGroupCell*)examplesCell atRow:(NSInteger)row {
    SENVoiceCommandSubGroup* group = [[self group] groups][row -1];
    NSString* groupCategoryName = [group localizedTitle];
    NSAttributedString* groupCommands = [self appendedCommands][row - 1];
    [[examplesCell categoryLabel] setText:groupCategoryName];
    [[examplesCell examplesLabel] setAttributedText:groupCommands];
    [examplesCell applyStyle];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self didScrollContentIn:scrollView];
}

#pragma mark - Clean up

- (void)dealloc {
    if (_collectionView) {
        [_collectionView setDataSource:nil];
        [_collectionView setDelegate:nil];
    }
}

@end
